{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-09-24";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "f25805d051090de7e09dd777f0596bccf9e9a586";
    hash = "sha256-AlKjt6+pcqlCO7wps+HBisHA37OV1yiCEotC8oeDnyw=";
  };
}
