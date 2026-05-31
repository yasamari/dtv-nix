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
      };
    };
}
