{ flake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [
    flake.nixosModules.amatsukaze
    flake.nixosModules.edcb
    flake.nixosModules.konomitv
    flake.nixosModules.px4
  ];

  nixpkgs.overlays = [
    (final: prev: {
      mirakurun = flake.packages.${system}.mirakurun;
    })
  ];
}
