{
  python3,
  fetchFromGitHub,
  ...
}:
python3.pkgs.atproto.overrideAttrs rec {
  version = "0.0.68";
  src = fetchFromGitHub {
    owner = "MarshalX";
    repo = "atproto";
    tag = "v${version}";
    hash = "sha256-z5/CLC2pxp2cFNZQsnQT96g8y2CFjNmiEatu8yEmYHw=";
  };
}
