{ fetchFromGitHub, ... }:
{
  version = "develop-a86ff8f";

  px4DrvSrc = fetchFromGitHub {
    owner = "yyya-nico";
    repo = "px4_drv";
    rev = "a86ff8fcb151e7ccb76b0a73532632cbbd0cc27a";
    hash = "sha256-LrybxOi2+E7AQmSJYNBrI3XbiFNFSTeeId3Lw9LD0Eo=";
  };
}
