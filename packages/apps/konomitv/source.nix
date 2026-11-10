{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-11-09";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "77969e1a55edd4b763499ae28babe8ed815535da";
    hash = "sha256-fedljc72iufZKRvgg/aIfrm4SI1sKDc9O9gslUfMbRM=";
  };
}
