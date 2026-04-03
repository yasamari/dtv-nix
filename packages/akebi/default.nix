{ pkgs, ... }:
pkgs.buildGoModule rec {
  pname = "akebi";
  version = "unstable-2026-04-03";

  src = pkgs.fetchFromGitHub {
    owner = "tsukumijima";
    repo = "Akebi";
    rev = "8ddba6a29b858567ab286b5d31daebf2ff683e94";
    hash = "sha256-KLKyVIzEaQNQYaU9NvNLiBqF0igzXZ7tkw7quS8Qzn8=";
  };

  vendorHash = "sha256-hYdp4RvRU7hhMVXrOAB9aN6RTJplBxWhJi9VNLpQ298=";
  subPackages = [ "https-server" ];

  env.CGO_ENABLED = 0;

  postInstall = ''
    mv "$out/bin/https-server" "$out/bin/akebi-https-server"
  '';

  meta = with pkgs.lib; {
    description = "Lightweight HTTPS reverse proxy used by KonomiTV";
    homepage = "https://github.com/tsukumijima/Akebi";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "akebi-https-server";
    platforms = platforms.linux;
  };
}
