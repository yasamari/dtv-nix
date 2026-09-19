{
  fetchFromGitHub,
  dotnetCorePackages,
  bash,
}:
let
  version = "1.1.0.1";

  src = fetchFromGitHub {
    owner = "rigaya";
    repo = "Amatsukaze";
    tag = version;
    hash = "sha256-AbkPGUA+itwJKmp6gFsHPlW5wRvqFKDwIPdmtV5xgqE=";
    fetchSubmodules = true;
  };

  dotnetSdk = dotnetCorePackages.sdk_10_0;
  dotnetRuntime = dotnetCorePackages.aspnetcore_10_0;

  mesonVersionPatch = ''
    substituteInPlace meson.build \
      --replace-fail 'version_full=$(git describe --tags) && \' 'version_full="${version}" && \' \
      --replace-fail 'version_short=$(git describe --abbrev=0 --tags) && \' 'version_short="${version}" && \'
  '';

  dotnetVersionPatch = ''
    substituteInPlace AmatsukazeServer/Version.sh \
      --replace-fail '/bin/bash' '${bash}/bin/bash' \
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
