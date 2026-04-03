{ flake, ... }:
{ ... }:
{
  imports = [
    flake.nixosModules.amatsukaze
    flake.nixosModules.konomitv
  ];
}
