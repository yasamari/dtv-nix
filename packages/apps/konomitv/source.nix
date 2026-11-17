{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-11-16";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "af98b172eb7a0e9df7683435c706c84bedd9231e";
    hash = "sha256-R/diHC9tL6BJHHYk5WhLl0voeS4OlBLR9d83H6/NfPw=";
  };
}
