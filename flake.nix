{
  description = "Pekmez invoice maker";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nix-community/naersk";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        fenix.follows = "fenix";
      };
    };
  };

  outputs =
    {
      self,
      fenix,
      flake-utils,
      naersk,
      nixpkgs,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
          # config.allowUnfree = true;
          overlays = [ fenix.overlays.default ];
        };

        toolchain =
          with fenix.packages.${system};
          combine [
            minimal.rustc
            minimal.cargo
            targets.x86_64-unknown-linux-musl.latest.rust-std
            targets.x86_64-pc-windows-gnu.latest.rust-std
            targets.aarch64-unknown-linux-gnu.latest.rust-std
            targets.aarch64-apple-darwin.latest.rust-std
          ];

        naersk' = naersk.lib.${system}.override {
          cargo = toolchain;
          rustc = toolchain;
        };

        naerskBuildPackage =
          target: args: naersk'.buildPackage (args // { CARGO_BUILD_TARGET = target; } // cargoConfig);

        cargoConfig = {
          # Tells Cargo to enable static compilation.
          # (https://doc.rust-lang.org/cargo/reference/config.html#targettriplerustflags)
          #
          # Note that the resulting binary might still be considered dynamically
          # linked by ldd, but that's just because the binary might have
          # position-independent-execution enabled.
          # (see: https://github.com/rust-lang/rust/issues/79624#issuecomment-737415388)
          CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_RUSTFLAGS = "-C target-feature=+crt-static";

          # Tells Cargo that it should use Wine to run tests.
          # (https://doc.rust-lang.org/cargo/reference/config.html#targettriplerunner)
          CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUNNER = pkgs.writeScript "wine-wrapper" ''

            export WINEPREFIX="$(mktemp -d)"
            exec wine64 $@
          '';
        };
      in
      rec {
        packages =
          let
            deps = {
              inherit naerskBuildPackage;
            };
          in
          {
            pekmez-x86_64-linux = pkgs.callPackage ./pkgs/x86_64-unknown-linux-musl.nix deps;
            pekmez-x86_64-windows = pkgs.callPackage ./pkgs/x86_64-pc-windows-gnu.nix deps;
            pekmez-aarch64-linux = pkgs.callPackage ./pkgs/aarch64-unknown-linux-gnu.nix deps;
            # aarch64-apple-darwin = pkgs.callPackage ./pkgs/aarch64-apple-darwin.nix deps;
            default = pkgs.callPackage ./pkgs/x86_64-unknown-linux-musl.nix deps;
          };

        devShells = {
          rust = pkgs.mkShell {
            packages = [
              (pkgs.fenix.complete.withComponents [
                "cargo"
                "clippy"
                "rust-src"
                "rustc"
                "rustfmt"
              ])
              pkgs.rust-analyzer
            ];
          };
          default = pkgs.mkShell (
            {
              inputsFrom = with packages; [
                pekmez-x86_64-linux
                pekmez-x86_64-windows
                pekmez-aarch64-linux
              ];
              CARGO_BUILD_TARGET = "x86_64-unknown-linux-musl";
            }
            // cargoConfig
          );
        };
      }
    );
}
