{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-11-06";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "b5c58ee57e52d2d69f8923b6d3e9d27cc29f1f96";
    hash = "sha256-Y/aIO0kprKc/rcMwD4/lqe3+5LgmYHiDYiuhaC8Yi6o=";
  };
}
