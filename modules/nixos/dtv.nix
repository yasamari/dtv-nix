{ flake, ... }:
{ ... }:
{
  imports = [
    flake.nixosModules.amatsukaze
    flake.nixosModules.edcb
    flake.nixosModules.konomitv
  ];
}
