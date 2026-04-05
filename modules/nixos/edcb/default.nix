{ flake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.edcb;

  stateDir = "/var/lib/edcb";
  defaultUser = "edcb";
  defaultGroup = "edcb";

  edcbLibs = [
    "EpgDataCap3.so"
    "SendTSTCP.so"
    "Write_Default.so"
    "RecName_Macro.so"
  ];

  linkEdcbLibs = lib.concatStringsSep "\n" (
    map (name: ''
      ln -sfn "${cfg.package}/lib/edcb/${name}" "$libDir/${name}"
    '') edcbLibs
  );

  bonDriver = flake.packages.${pkgs.stdenv.hostPlatform.system}.bondriver_linuxmirakc;

  generateBonDriverIni =
    priority:
    lib.generators.toINI { } {
      GLOBAL = {
        SERVER_HOST = cfg.bonDriver.mirakc.host;
        SERVER_PORT = cfg.bonDriver.mirakc.port;
        SERVER_SOCKPATH = cfg.bonDriver.mirakc.socketPath;
        SERVER_TYPE = cfg.bonDriver.mirakc.serverType;
        DECODE_B25 = 1;
        PRIORITY = priority;
        SERVICE_SPLIT = 0;
      };
    };

  initializeState = pkgs.writeShellScript "edcb-initialize-state" ''
    set -eu

    libDir="${stateDir}/lib"
    httpPublicDir="${stateDir}/HttpPublic"
    packageHttpPublicDir="${cfg.package}/share/edcb/ini/HttpPublic"
    packageSettingDir="${cfg.package}/share/edcb/ini/Setting"

    mkdir -p "$libDir"

    settingDir="${stateDir}/Setting"

    mkdir -p "$settingDir"

    if [ ! -e "${stateDir}/Bitrate.ini" ]; then
      install -m 0644 "${cfg.package}/share/edcb/ini/Bitrate.ini" "${stateDir}/Bitrate.ini"
    fi

    if [ ! -e "${stateDir}/BonCtrl.ini" ]; then
      install -m 0644 "${cfg.package}/share/edcb/ini/BonCtrl.ini" "${stateDir}/BonCtrl.ini"
    fi

    if [ ! -e "${stateDir}/ContentTypeText.txt" ]; then
      install -m 0644 "${cfg.package}/share/edcb/ini/ContentTypeText.txt" "${stateDir}/ContentTypeText.txt"
    fi

    if [ ! -e "$httpPublicDir" ]; then
      ln -s "$packageHttpPublicDir" "$httpPublicDir"
    fi

    if [ ! -e "$settingDir/HttpPublic.ini" ]; then
      install -m 0644 "$packageSettingDir/HttpPublic.ini" "$settingDir/HttpPublic.ini"
    fi

    if [ ! -e "$settingDir/XCODE_OPTIONS.lua" ]; then
      install -m 0644 "$packageSettingDir/XCODE_OPTIONS.lua" "$settingDir/XCODE_OPTIONS.lua"
    fi

    if [ ! -e "${stateDir}/EpgTimerSrv.ini" ]; then
      install -m 0644 "${./EpgTimerSrv.ini}" "${stateDir}/EpgTimerSrv.ini"
    fi

    ${linkEdcbLibs}

    srcSo="${bonDriver}/lib/edcb/BonDriver_LinuxMirakc.so"

    install -m 0644 "$srcSo" "$libDir/BonDriver_LinuxMirakc.so"
    install -m 0644 "$srcSo" "$libDir/BonDriver_LinuxMirakc_T.so"
    install -m 0644 "$srcSo" "$libDir/BonDriver_LinuxMirakc_S.so"

    install -m 0644 "${cfg.bonDriver.chSet5File}" "$settingDir/ChSet5.txt"
    install -m 0644 "${cfg.bonDriver.multiChSet4File}" "$settingDir/BonDriver_LinuxMirakc(LinuxMirakc).ChSet4.txt"
    install -m 0644 "${cfg.bonDriver.terrestrialChSet4File}" "$settingDir/BonDriver_LinuxMirakc_T(LinuxMirakc).ChSet4.txt"
    install -m 0644 "${cfg.bonDriver.satelliteChSet4File}" "$settingDir/BonDriver_LinuxMirakc_S(LinuxMirakc).ChSet4.txt"

    install -m 0644 "${pkgs.writeText "BonDriver_LinuxMirakc.so.ini" (generateBonDriverIni 8)}" "$libDir/BonDriver_LinuxMirakc.so.ini"
    install -m 0644 "${pkgs.writeText "BonDriver_LinuxMirakc_T.so.ini" (generateBonDriverIni 9)}" "$libDir/BonDriver_LinuxMirakc_T.so.ini"
    install -m 0644 "${pkgs.writeText "BonDriver_LinuxMirakc_S.so.ini" (generateBonDriverIni 10)}" "$libDir/BonDriver_LinuxMirakc_S.so.ini"
  '';
in
{
  options.services.edcb = {
    enable = lib.mkEnableOption "EDCB (EpgTimerSrv) サービスを有効化します。";

    package = lib.mkOption {
      type = lib.types.package;
      default = flake.packages.${pkgs.stdenv.hostPlatform.system}.edcb;
      defaultText = lib.literalExpression "flake.packages.${pkgs.stdenv.hostPlatform.system}.edcb";
      description = "実行に使用する EDCB パッケージ。";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = "EDCB サービスを実行するユーザー名。";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = defaultGroup;
      description = "EDCB サービスのプライマリグループ名。";
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "EDCB プロセスに追加で付与する補助グループ。";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "EDCB の HTTP/TCP ポートを開放します。";
    };

    httpPort = lib.mkOption {
      type = lib.types.ints.between 1 65535;
      default = 5510;
      description = "ファイアウォール開放で使用する EDCB HTTP ポート番号。";
    };

    tcpPort = lib.mkOption {
      type = lib.types.ints.port;
      default = 4510;
      description = "ファイアウォール開放で使用する EDCB TCP ポート番号。";
    };

    bonDriver = {
      multiChSet4File = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "BonDriver_mirakc(LinuxMirakc).ChSet4.txtのパス。";
      };
      terrestrialChSet4File = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "BonDriver_mirakc_T(LinuxMirakc).ChSet4.txtのパス。";
      };
      satelliteChSet4File = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "BonDriver_mirakc_S(LinuxMirakc).ChSet4.txtのパス。";
      };

      chSet5File = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "ChSet5.txtのパス。";
      };

      mirakc = {
        serverType = lib.mkOption {
          type = lib.types.enum [
            "http"
            "unix"
          ];
          default = if config.services.mirakurun.enable then "unix" else "http";
          description = "Mirakurunに接続する方法。unixかhttpを選択します。";
        };

        socketPath = lib.mkOption {
          type = lib.types.path;
          default = config.services.mirakurun.unixSocket;
          description = "MirakurunのUNIXドメインソケットのパス。serverTypeがhttpの場合は使用されません。";
        };

        host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = "Mirakurunのホスト名またはIPアドレス。serverTypeがunixの場合は使用されません。";
        };

        port = lib.mkOption {
          type = lib.types.ints.between 1 65534;
          default = 40772;
          description = "Mirakurunのポート番号。serverTypeがunixの場合は使用されません。";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = stateDir;
      createHome = false;
    };

    systemd.services.edcb = {
      description = "EDCB (EpgTimerSrv)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        SupplementaryGroups = cfg.extraGroups;
        StateDirectory = "edcb";
        WorkingDirectory = stateDir;
        ReadWritePaths = [ stateDir ];
        ExecStartPre = [ "${initializeState}" ];
        ExecStart = "${cfg.package}/bin/EpgTimerSrv";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.httpPort
      cfg.tcpPort
    ];
  };
}
