{ fetchFromGitHub, ... }:
{
  version = "0.6.11";

  px4DrvSrc = fetchFromGitHub {
    owner = "yyya-nico";
    repo = "px4_drv";
    rev = "v0.6.11";
    hash = "sha256-TmwuyjjPRB5UkARacxCeLfMJJGysvyfEhyXFpicXCTw=";
  };
}
