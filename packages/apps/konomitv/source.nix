{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-10-31";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "eac5d8bbf9104570b78661832a481a7fbc9802f8";
    hash = "sha256-bcwIwzba7mKPCSkSOq0iFk9VcvyycA0uu0jQ6VIOc3k=";
  };
}
