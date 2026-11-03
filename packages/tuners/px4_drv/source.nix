{ fetchFromGitHub, ... }: rec {
  version = "0.7.1";

  px4DrvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "px4_drv";
    rev = "v${version}";
    hash = "sha256-MP0ubv/J61X9OB9mdU7VVmq8OShpDKB1CBY7C2mR2hk=";
  };
}
