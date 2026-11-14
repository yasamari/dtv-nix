{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-11-13";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "f6ce15afea9e1fd61ad94822fab047547226355d";
    hash = "sha256-V5p1/+ER1jcXf1/sWmKvyGNQ4OTRdL2BE97gkNeWZns=";
  };
}
