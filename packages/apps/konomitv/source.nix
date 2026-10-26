{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-10-25";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "1e5a0a1ba65a038e983c451620ea8224b342b7c0";
    hash = "sha256-+mYVhE1qln988HvRct53CSUM5k7m+3+vCWQlhUnPous=";
  };
}
