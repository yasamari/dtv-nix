{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-10-07";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "07755942152b312a23ffb14b2877cd01ea48e62f";
    hash = "sha256-PS2sE/pPhBIWT1COBTctrU0I+sHn28OUOgjqikTHzFk=";
  };
}
