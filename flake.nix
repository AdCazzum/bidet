{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-protobuf.url = "github:NixOS/nixpkgs/c5dd43934613ae0f8ff37c59f61c507c2e8f980d";
    barretenberg = {
      url = "https://github.com/AztecProtocol/aztec-packages/releases/download/v1.0.0-staging.3/barretenberg-amd64-linux.tar.gz";
      flake = false;
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-root.url = "github:srid/flake-root";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ config, lib, ... }: {
      systems = [ "x86_64-linux" ];

      imports = with inputs; [
        git-hooks.flakeModule
        treefmt-nix.flakeModule
        flake-root.flakeModule
      ];

      perSystem = { config, pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.rust-overlay.overlays.default ];
        };
        packages = {
          noir = pkgs.callPackage ./noir.nix {
            protobuf_29 = inputs.nixpkgs-protobuf.legacyPackages.${system}.protobuf;
          };
          barretenberg = pkgs.writeScriptBin "bb" ''
            ${inputs.barretenberg} $@
          '';
        };

        treefmt.config = {
          flakeFormatter = true;
          flakeCheck = true;
          programs = {
            nixpkgs-fmt.enable = true;
          };
        };

        pre-commit = {
          check.enable = false;
          settings.hooks = {
            treefmt = {
              enable = true;
              package = config.treefmt.build.wrapper;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          packages = with config.packages; [
            noir
            barretenberg
          ];

          inputsFrom = [ config.flake-root.devShell ];

          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };
      };
    });
}
