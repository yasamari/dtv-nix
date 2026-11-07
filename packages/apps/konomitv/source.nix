{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-11-06";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "5589ee08d0afbb8d0203465fb47185e6c1e1277c";
    hash = "sha256-cIsMTqv/w0nHOnXIAYi2CVcLQ7LiLKnNL4ofXjG6glc=";
  };
}
