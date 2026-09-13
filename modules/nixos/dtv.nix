{ ... }:
{
  imports = [
    ./amatsukaze.nix
    ./edcb
    ./konomitv.nix
    ./px4.nix
  ];

  nixpkgs.overlays = [ (import ../../overlay.nix) ];
}
