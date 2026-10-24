{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-10-24";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "9a11093953c057073e021ef07a97a958662fddad";
    hash = "sha256-S6wajy1zhb4ZaRgut+Py+aS+qCVYQFCxf3Sva5mFYgs=";
  };
}
