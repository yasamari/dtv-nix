{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
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
          overlays = [ self.overlays.default ];
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
        amatsukaze = import ./modules/nixos/amatsukaze.nix;
        edcb = import ./modules/nixos/edcb;
        konomitv = import ./modules/nixos/konomitv.nix;
        px4 = import ./modules/nixos/px4.nix;
        dtv = import ./modules/nixos/dtv.nix;
        default = import ./modules/nixos/dtv.nix;
      };
    };
}
