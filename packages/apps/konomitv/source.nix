{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-11-05";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "941d5a24ba6f5dbddab4a9bebed6eb0a7edf71c8";
    hash = "sha256-ccgP515n5436XoWuBoSfcFq0ljR4HzrJdteujvmwJ+s=";
  };
}
