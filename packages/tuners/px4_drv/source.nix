{ fetchFromGitHub, ... }: rec {
  version = "0.6.12";

  px4DrvSrc = fetchFromGitHub {
    owner = "yyya-nico";
    repo = "px4_drv";
    rev = "v${version}";
    hash = "sha256-ijlN6RZnj2QVoXv0ianZxMP+ivzbVDtVhivDstcC414=";
  };
}
