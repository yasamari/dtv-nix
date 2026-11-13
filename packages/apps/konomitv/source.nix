{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-11-12";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "3c4a7cb6b51534a9d94d392f25be2d3524fce35a";
    hash = "sha256-Sn6Ppw2tVomgtBkF4o/CG+2vNkcyEsNmhgVxw92NLQw=";
  };
}
