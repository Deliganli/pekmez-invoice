{
  naerskBuildPackage,
  pkgs,
  ...
}:
let
  pkgsWin64 = pkgs.pkgsCross.mingwW64;
  cc = pkgsWin64.stdenv.cc;
in
naerskBuildPackage "x86_64-pc-windows-gnu" rec {
  strictDeps = true;
  src = pkgs.lib.cleanSource ../.;
  nativeBuildInputs = with pkgs; [
    perl # Needed to build vendored OpenSSL. Not sure if we have
    # wineWowPackages.stable # Needed for tests, which doesn't work
  ];
  depsBuildBuild = [
    cc
    pkgsWin64.windows.pthreads
  ];

  auditable = false;
  doCheck = false;

  TARGET_CC = "${cc}/bin/${cc.targetPrefix}cc";
  CARGO_BUILD_RUSTFLAGS = [
    "-C"
    "linker=${TARGET_CC}"
  ];

  CC = "${cc}/bin/${cc.targetPrefix}cc";
  LD = "${cc}/bin/${cc.targetPrefix}cc";
}
