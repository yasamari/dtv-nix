{
  pkgs,
  perSystem,
}:
let
  version = "1.0.7.3";

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "Amatsukaze";
    tag = version;
    hash = "sha256-F/UBqqMvCRd3ueqtrLLCnwq5uhiPaw+kNBJUFlLSO8E=";
    fetchSubmodules = true;
  };

  dotnetSdk = pkgs.dotnetCorePackages.sdk_10_0;
  dotnetRuntime = pkgs.dotnetCorePackages.aspnetcore_10_0;

  mesonVersionPatch = ''
    substituteInPlace meson.build \
      --replace-fail 'version_full=$(git describe --tags) && \' 'version_full="${version}" && \' \
      --replace-fail 'version_short=$(git describe --abbrev=0 --tags) && \' 'version_short="${version}" && \'
  '';

  dotnetVersionPatch = ''
    substituteInPlace AmatsukazeServer/Version.sh \
      --replace-fail '/bin/bash' '${pkgs.bash}/bin/bash' \
      --replace-fail 'VER=$(git describe --tags)' 'VER="${version}"'
    substituteInPlace AmatsukazeServer/Properties/AssemblyInfo.tt \
      --replace-fail 'AssemblyVersion("0.0.0.0")' 'AssemblyVersion("@SHORTVERSION@")'
    (cd AmatsukazeServer && ./Version.sh)
  '';
in
{
  inherit
    version
    src
    dotnetSdk
    dotnetRuntime
    mesonVersionPatch
    dotnetVersionPatch
    ;
}
