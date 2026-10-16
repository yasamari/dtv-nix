{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-10-15";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "9a5e8d3f0d6232896d91d11cc58f4693bfaa9600";
    hash = "sha256-j3lt/8P7WeJYro1bG5rhlcsbw5/bxnqBn+x239T5xWk=";
  };
}
