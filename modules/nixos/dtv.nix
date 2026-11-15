{ self }:
{ pkgs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [
    self.nixosModules.amatsukaze
    self.nixosModules.edcb
    self.nixosModules.konomitv
    self.nixosModules.px4
  ];
}
