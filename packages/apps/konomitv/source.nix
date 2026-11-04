{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-11-03";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "11b49e4c9af5af2d51dc4088bb1354ed388b1a49";
    hash = "sha256-oimmQVTQicAY1z5si78frC/PANvuVIc/3q02HDu4wj8=";
  };
}
