{
  naerskBuildPackage,
  pkgs,
  ...
}:
let
  inherit (pkgs.pkgsCross.aarch64-apple-darwin.stdenv) cc;
in
naerskBuildPackage "aarch64-apple-darwin" rec {
  src = ../.;
  doCheck = true;

  # TARGET_CC = "${cc}/bin/${cc.targetPrefix}cc";
  # CARGO_BUILD_RUSTFLAGS = [
  #   "-C"
  #   "linker=${TARGET_CC}"
  # ];
  #
  # CC = "${cc}/bin/${cc.targetPrefix}cc";
  # LD = "${cc}/bin/${cc.targetPrefix}cc";

  buildPhaseCargoCommand = "cargo zigbuild --release --message-format json-render-diagnostics";

  depsBuildBuild = [
    pkgs.zig
    pkgs.cargo-zigbuild
    pkgs.darwin.xcode_12_2
  ];

  preBuild = ''

    export SDKROOT=${pkgs.darwin.xcode_12_2}/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk

    export XDG_CACHE_HOME=$TMPDIR/xdg_cache
    mkdir -p $XDG_CACHE_HOME
    export CARGO_ZIGBUILD_CACHE_DIR=$TMPDIR/cargo-zigbuild-cache
    mkdir -p $CARGO_ZIGBUILD_CACHE_DIR
    export CC=zigcc
    export CXX=zigc++
  '';

  installPhaseCommand = ''

    mkdir -p $out/aarch64-apple-darwin
    cp target/aarch64-apple-darwin/release/liana-gui $out/aarch64-apple-darwin
    cp target/aarch64-apple-darwin/release/lianad $out/aarch64-apple-darwin
    cp target/aarch64-apple-darwin/release/liana-cli $out/aarch64-apple-darwin
  '';
}
