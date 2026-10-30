{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-10-30";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "1319cf39ea098ecca31cee4e2e59cffb94136292";
    hash = "sha256-OINr8ftleUfeudGi3rg7m20wbpTn0Vs91OD29U0AewY=";
  };
}
