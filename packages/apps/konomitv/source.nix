{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-10-26";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "6b48bb48fad42333a4b22a308c970e61ebfd43be";
    hash = "sha256-Y+aIp4FzoCDyuqMX79Q68njLfU9AbGIH76UFaBMl2hc=";
  };
}
