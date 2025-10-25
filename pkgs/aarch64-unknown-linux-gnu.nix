{
  naerskBuildPackage,
  pkgs,
  ...
}:
let
  inherit (pkgs.pkgsCross.aarch64-multiplatform.stdenv) cc;
in
naerskBuildPackage "aarch64-unknown-linux-gnu" rec {
  src = ../.;
  doCheck = false;

  TARGET_CC = "${cc}/bin/${cc.targetPrefix}cc";
  CARGO_BUILD_RUSTFLAGS = [
    "-C"
    "linker=${TARGET_CC}"
  ];

  CC = "${cc}/bin/${cc.targetPrefix}cc";
  LD = "${cc}/bin/${cc.targetPrefix}cc";
}
