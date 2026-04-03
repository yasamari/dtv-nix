{ flake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.konomitv;

  stateDir = "/var/lib/konomitv";
  defaultUser = "konomitv";
  defaultGroup = "konomitv";

  settingsFormat = pkgs.formats.yaml { };

  hasCustomSettings = cfg.settings != { };

  configSource =
    if hasCustomSettings then
      settingsFormat.generate "konomitv-config.yaml" cfg.settings
    else
      "${cfg.package}/share/konomitv/config.yaml";

  prepareConfig = pkgs.writeShellScript "konomitv-prepare-config" ''
    set -eu

    config_path="${stateDir}/config.yaml"

    if [ "${if cfg.mutableSettings then "true" else "false"}" = "true" ]; then
      if [ -L "$config_path" ]; then
        ${pkgs.coreutils}/bin/cp --dereference --no-preserve=mode,ownership "$config_path" "$config_path.tmp"
        ${pkgs.coreutils}/bin/mv -f "$config_path.tmp" "$config_path"
        ${pkgs.coreutils}/bin/chmod 0644 "$config_path"
      elif [ ! -e "$config_path" ]; then
        ${pkgs.coreutils}/bin/cp --no-preserve=mode,ownership "${configSource}" "$config_path"
        ${pkgs.coreutils}/bin/chmod 0644 "$config_path"
      fi
    else
      ${pkgs.coreutils}/bin/ln -sfn "${configSource}" "$config_path"
    fi
  '';
in
{
  options.services.konomitv = {
    enable = lib.mkEnableOption "KonomiTV サービスを有効化します。";

    package = lib.mkOption {
      type = lib.types.package;
      default = flake.packages.${pkgs.stdenv.hostPlatform.system}.konomitv;
      defaultText = lib.literalExpression "flake.packages.${pkgs.stdenv.hostPlatform.system}.konomitv";
      description = "実行に使用する KonomiTV パッケージ。";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = "KonomiTV サービスを実行するユーザー名。";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = defaultGroup;
      description = "KonomiTV サービスのプライマリグループ名。";
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "KonomiTV プロセスに追加で付与する補助グループ。録画ファイルの保存先などのアクセス権限を調整するために使用できます。";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "KonomiTV が使用するポートを開放する。";
    };

    mutableSettings = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "KonomiTV から設定を変更することを許可するかどうか。true の場合は config.yaml が存在しない初回のみ Nix の設定を反映し、以降の KonomiTV 側の変更を保持します。false の場合は Nix が生成した config.yaml へのシンボリックリンクで固定します。";
    };

    settings = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = { };
      };
      description = ''
        `config.yaml` を生成するための設定。
        `services.konomitv.settings.*` に KonomiTV の設定を YAML 相当の構造で記述します。
      '';
      example = lib.literalExpression ''
        {
          general.backend = "Mirakurun";
          general.mirakurun_url = "http://127.0.0.1:40772/";
          server.port = 7000;
          video.recorded_folders = [ "/srv/recorded" ];
          capture.upload_folders = [ "/srv/capture" ];
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = stateDir;
      createHome = false;
    };

    systemd.services.konomitv = {
      description = "KonomiTV server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        SupplementaryGroups = cfg.extraGroups;
        StateDirectory = "konomitv";
        WorkingDirectory = stateDir;
        ReadWritePaths = [ stateDir ];
        ExecStartPre = [ "${prepareConfig}" ];
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 5;
      };

      environment = {
        XDG_STATE_HOME = "/var/lib";
        KONOMITV_CONFIG_YAML_PATH = "${stateDir}/config.yaml";
        KONOMITV_DATA_DIR = "${stateDir}/data";
        KONOMITV_LOGS_DIR = "${stateDir}/logs";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      (if (lib.hasAttrByPath [ "server" "port" ] cfg.settings) then cfg.settings.server.port else 7000)
    ];
  };
}
