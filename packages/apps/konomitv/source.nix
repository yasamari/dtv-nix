{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-10-21";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "1a10aa05fd278a4de28d4af88e6aa04ab6373f62";
    hash = "sha256-uUeExGODpEJzDI7QaalQI+unkhunmP/TLxNMIDluCtY=";
  };
}
