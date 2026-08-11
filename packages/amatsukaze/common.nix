{
  pkgs,
  perSystem,
}:
let
  version = "1.0.8.7";

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "Amatsukaze";
    tag = version;
    hash = "sha256-egKAxc6PGU5ljY9YWaDW3SwUd5BX229J+dUXq/53Jck=";
    fetchSubmodules = true;
  };

  danmaku2ass = pkgs.fetchFromGitHub {
    owner = "m13253";
    repo = "danmaku2ass";
    rev = "ced881747670c2eb1c0dbd292c2a567f444b056a";
    hash = "sha256-yhfioN3/E46vFU1xT68OEM2OymBsB5XI+8WdotD745o=";
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
    danmaku2ass
    dotnetSdk
    dotnetRuntime
    mesonVersionPatch
    dotnetVersionPatch
    ;
}
