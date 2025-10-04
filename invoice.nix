{
  lib,
  stdenv,
  pkgs,
  # typst,
  # getopt,
  writeShellApplication,
  ...
}:
let
  program = writeShellApplication {
    name = "pekmez-invoice";
    runtimeInputs = with pkgs; [
      typst
      getopt
      coreutils
    ];
    # don't know what I am doing, copied from somebody who does
    # https://stackoverflow.com/a/29754866/4327918
    text = ''
      # ignore errexit with `&& true`
      getopt --test > /dev/null && true
      if [[ $? -ne 4 ]]; then
          echo 'getopt --test failed in this environment.'
          exit 1
      fi

      LONGOPTS=invoice-date:,invoice-number:,items:,config:,output:
      OPTIONS=d:n:i:o:c:

      # -temporarily store output to be able to check for errors
      # -activate quoting/enhanced mode (e.g. by writing out “--options”)
      # -pass arguments only via   -- "$@"   to separate them correctly
      # -if getopt fails, it complains itself to stderr
      PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@") || exit 2
      # read getopt’s output this way to handle the quoting right:
      eval set -- "$PARSED"

      configDir=''${XDG_CONFIG_HOME:-$HOME/.config}/pekmez-invoice
      # mkdir -p $configDir
      # cp -n lib/details.yaml "$configDir/details.yaml"

      outFile="''${TMPDIR:-/tmp}/invoice.pdf"
      configFile=''${configDir}/details.yaml
      invoiceDate=$(date +%d.%m.%Y)
      invoiceNumber=
      items=

      while true; do
          case "$1" in
              -o|--output)
                  outFile="$2"
                  shift 2
                  ;;
              -c|--config)
                  configFile="$2"
                  shift 2
                  ;;
              -d|--invoice-date)
                  invoiceDate="$2"
                  shift 2
                  ;;
              -n|--invoice-number)
                  invoiceNumber="$2"
                  shift 2
                  ;;
              -i|--items)
                  items="$2"
                  shift 2
                  ;;
              --)
                  shift
                  break
                  ;;
              *)
                  echo "Programming error"
                  exit 3
                  ;;
          esac
      done

      ABS_CONFIG_FILE=$(realpath "$configFile")
      SCRIPT_DIR=$( cd -- "$( dirname -- "''${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

      typst compile \
          --root / \
          --input config="$ABS_CONFIG_FILE" \
          --input date="$invoiceDate" \
          --input number="$invoiceNumber" \
          --input items="$items" \
          "$SCRIPT_DIR/../lib/pekmez-invoice/invoice.typ" "$outFile"
    '';
  };
in
stdenv.mkDerivation (final: {
  pname = "pekmez-invoice";
  version = "0.1.0";
  src = ./src;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -D -m 755 ${lib.getExe program} -t $out/bin/
    install -D -m 644 ${final.src}/invoice.typ -t $out/lib/pekmez-invoice/

    runHook postInstall
  '';

  meta = {
    mainProgram = "pekmez-invoice";
  };
})
