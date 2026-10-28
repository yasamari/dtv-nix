{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-10-28";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "8cf7f0fd3110a61c70c24a467eaaa265a16e2711";
    hash = "sha256-rdMSjz203R8pwY0y0VsrN47axCsIRWeNdEBgiqeXQjg=";
  };
}
