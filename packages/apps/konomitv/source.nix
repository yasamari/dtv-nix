{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-09-09";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "13649f3f1f37a9a535210863cefd4672cfb8e146";
    hash = "sha256-UIN5riv7P019tA9B85ZuBJfp8MZhfLob+uZanuseKzM=";
  };
}
