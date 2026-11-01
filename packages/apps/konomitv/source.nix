{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-11-01";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "ed4e4b8d5c1b2f28d3e1baff5baf10506c6a9c74";
    hash = "sha256-zXvZlrWyvwt9isA+dGj+My7FcNse8I/+kCCK6iIO61I=";
  };
}
