{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-10-29";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "b79e0703e29a94b534b9ac9e41880b2a5bc54f13";
    hash = "sha256-pB9pd8TuWJrOJx5Wh41268nW9YIZlxmiTzKgeioPGag=";
  };
}
