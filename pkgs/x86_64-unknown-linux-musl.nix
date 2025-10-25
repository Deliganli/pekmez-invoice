{
  naerskBuildPackage,
  pkgs,
  ...
}:
naerskBuildPackage "x86_64-unknown-linux-musl" {
  src = ../.;
  doCheck = true;
  nativeBuildInputs = with pkgs; [ pkgsStatic.stdenv.cc ];
}
