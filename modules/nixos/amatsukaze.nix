{ flake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.amatsukaze;

  stateDir = "/var/lib/amatsukaze";
  defaultUser = "amatsukaze";
  defaultGroup = "amatsukaze";

  defaultsDir = "${cfg.package}/share/amatsukaze";

  copyIfMissing = src: dst: ''
    if [ ! -d "${dst}" ]; then
      ${pkgs.coreutils}/bin/cp -r --no-preserve=mode,ownership "${src}" "${dst}"
    fi
  '';

  initializeState = pkgs.writeShellScript "amatsukaze-initialize-state" ''
    set -eu

    ${copyIfMissing "${defaultsDir}/drcs" "${stateDir}/drcs"}
    ${copyIfMissing "${defaultsDir}/JL" "${stateDir}/JL"}
    ${copyIfMissing "${defaultsDir}/profile" "${stateDir}/profile"}
    ${copyIfMissing "${defaultsDir}/bat_linux" "${stateDir}/bat"}
    ${copyIfMissing "${defaultsDir}/avs" "${stateDir}/avs"}
  '';
in
{
  options.services.amatsukaze = {
    enable = lib.mkEnableOption "AmatsukazeServerとWebUIを有効化します。";

    package = lib.mkOption {
      type = lib.types.package;
      default = flake.packages.${pkgs.stdenv.hostPlatform.system}.amatsukaze;
      defaultText = lib.literalExpression "flake.packages.${pkgs.stdenv.hostPlatform.system}.amatsukaze";
      description = "実行に使用するAmatsukazeパッケージ。";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = "Amatsukazeサービスを実行するユーザー名。";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = defaultGroup;
      description = "Amatsukazeサービスのプライマリグループ名。";
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Amatsukazeプロセスに追加で付与する補助グループ。録画ファイルの保存先などのアクセス権限を調整するために使用できます。";
    };

    port = lib.mkOption {
      type = lib.types.ints.between 1 65534;
      default = 32770;
      description = "AmatsukazeServerのポート番号。WebUIはこのポート+1で動作します。";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "AmatsukazeServerとWebUIのポートを開放します。";
    };

    extraReadWritePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "systemdユニットに追加で書き込み許可するパス。録画ファイルの保存先などを指定してください。";
      example = [
        "/mnt/recordings"
        "/srv/amatsukaze"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups = lib.mkIf (cfg.group == defaultGroup) {
      ${defaultGroup} = { };
    };

    users.users = lib.mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        isSystemUser = true;
        group = cfg.group;
        home = stateDir;
        createHome = false;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.port
      (cfg.port + 1)
    ];

    systemd.services.amatsukaze = {
      description = "Amatsukaze server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        SupplementaryGroups = cfg.extraGroups;
        StateDirectory = "amatsukaze";
        WorkingDirectory = stateDir;
        ReadWritePaths = [ stateDir ] ++ cfg.extraReadWritePaths;
        ExecStartPre = [ "${initializeState}" ];
        ExecStart = "${lib.getExe cfg.package} --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
