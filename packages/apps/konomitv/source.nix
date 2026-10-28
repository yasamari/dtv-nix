{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-10-28";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "e67d8acc7cd0fc88fec12a5593cab2664ac69542";
    hash = "sha256-8PwJSheTqEjudzKsbULn8TDeNq1w7ipRPGc86N+fKJI=";
  };
}
