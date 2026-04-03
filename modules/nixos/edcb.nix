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
      ${pkgs.coreutils}/bin/ln -sfn "${cfg.package}/lib/edcb/${name}" "$libDir/${name}"
    '') edcbLibs
  );

  bonDriver = flake.packages.${pkgs.stdenv.hostPlatform.system}.bondriver_linuxmirakc;

  setupBonDriver = ''
    srcSo="${bonDriver}/lib/edcb/BonDriver_LinuxMirakc.so"

    if [ -f "$srcSo" ]; then
      ${pkgs.coreutils}/bin/install -m 0644 "$srcSo" "$libDir/BonDriver_LinuxMirakc.so"
      ${pkgs.coreutils}/bin/install -m 0644 "$srcSo" "$libDir/BonDriver_LinuxMirakc_T.so"
      ${pkgs.coreutils}/bin/install -m 0644 "$srcSo" "$libDir/BonDriver_LinuxMirakc_S.so"
    fi
  '';

  initializeState = pkgs.writeShellScript "edcb-initialize-state" ''
            set -eu

            libDir="${stateDir}/lib"

            ${pkgs.coreutils}/bin/mkdir -p "$libDir"

            if [ ! -e "${stateDir}/Bitrate.ini" ]; then
              ${pkgs.coreutils}/bin/install -m 0644 "${cfg.package}/share/edcb/ini/Bitrate.ini" "${stateDir}/Bitrate.ini"
            fi

            if [ ! -e "${stateDir}/BonCtrl.ini" ]; then
              ${pkgs.coreutils}/bin/install -m 0644 "${cfg.package}/share/edcb/ini/BonCtrl.ini" "${stateDir}/BonCtrl.ini"
            fi

            if [ ! -e "${stateDir}/ContentTypeText.txt" ]; then
              ${pkgs.coreutils}/bin/install -m 0644 "${cfg.package}/share/edcb/ini/ContentTypeText.txt" "${stateDir}/ContentTypeText.txt"
            fi

            if [ ! -e "${stateDir}/HttpPublic" ]; then
              ${pkgs.coreutils}/bin/cp -a "${cfg.package}/share/edcb/ini/HttpPublic" "${stateDir}/HttpPublic"
            fi

        if [ ! -e "${stateDir}/EpgTimerSrv.ini" ]; then
          ${pkgs.coreutils}/bin/cat > "${stateDir}/EpgTimerSrv.ini" <<'EOF'
    [SET]
    EnableHttpSrv=2
    HttpAccessControlList=+127.0.0.0/8,+10.0.0.0/8,+172.16.0.0/12,+192.168.0.0/16,+169.254.0.0/16,+100.64.0.0/10
    EnableTCPSrv=1
    TCPIPv6=0
    TCPAccessControlList=+127.0.0.0/8,+10.0.0.0/8,+172.16.0.0/12,+192.168.0.0/16,+169.254.0.0/16,+100.64.0.0/10
    EOF
        fi

            ${linkEdcbLibs}
            ${setupBonDriver}
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
      type = lib.types.ints.between 1 65535;
      default = 4510;
      description = "ファイアウォール開放で使用する EDCB TCP ポート番号。";
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
