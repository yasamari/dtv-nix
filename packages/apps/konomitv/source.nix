{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-10-28";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "ef4edcab5ecddf37f383baefc80f0f3ab0ec444a";
    hash = "sha256-6CyCc86ygDzM1NB4CtPACgmKE1690dq9VtOdVzxzXXM=";
  };
}
