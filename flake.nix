{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pyproject-nix,
      uv2nix,
      pyproject-build-systems,
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "intel-media-sdk-23.2.2"
            ];
          };
          overlays = [
            self.overlays.default
            (final: prev: {
              inherit pyproject-nix uv2nix pyproject-build-systems;
            })
          ];
        };
        packages = self.overlays.default pkgs pkgs;
      in
      {
        inherit packages;
        checks = packages;
        formatter = pkgs.nixfmt-tree;
      }
    )
    // {
      overlays.default = import ./overlay.nix;

      nixosModules = {
        amatsukaze = import ./modules/nixos/amatsukaze.nix { inherit self; };
        edcb = import ./modules/nixos/edcb { inherit self; };
        konomitv = import ./modules/nixos/konomitv.nix { inherit self; };
        px4 = import ./modules/nixos/px4.nix { inherit self; };
        dtv = import ./modules/nixos/dtv.nix { inherit self; };
        default = self.nixosModules.dtv;
      };
    };
}
