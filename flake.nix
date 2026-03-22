{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      nixpkgs = {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "intel-media-sdk-23.2.2"
          ];
        };
        overlays = [
          (_self: super: {
            intel-media-sdk = super.intel-media-sdk.overrideAttrs (old: {
              cmakeFlags = old.cmakeFlags ++ [ "-DCMAKE_CXX_STANDARD=17" ];
              NIX_CFLAGS_COMPILE = "-std=c++17";
            });
          })
        ];
      };
    };
}
