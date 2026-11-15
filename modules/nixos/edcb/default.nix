{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.edcb;

  system = pkgs.stdenv.hostPlatform.system;
  stateDir = "/var/lib/edcb";
  defaultUser = "edcb";
  defaultGroup = "edcb";

  edcbLibs = [
    "EpgDataCap3.so"
    "SendTSTCP.so"
    "Write_Default.so"
    "RecName_Macro.so"
  ];

  postCommandFiles = {
    PostRecEnd = cfg.postRecEndCommand;
    PostAddReserve = cfg.postAddReserveCommand;
    PostChgReserve = cfg.postChgReserveCommand;
    PostRecStart = cfg.postRecStartCommand;
    PostNotify = cfg.postNotifyCommand;
  };

  postCommandSetup = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: command:
      if command == null then
        ''
          rm -f "${stateDir}/${name}.sh"
        ''
      else
        ''
          ln -sfn "${pkgs.writeShellScript "${name}.sh" command}" "${stateDir}/${name}.sh"
        ''
    ) postCommandFiles
  );

  linkEdcbLibs = lib.concatStringsSep "\n" (
    map (name: ''
      ln -sfn "${cfg.package}/lib/edcb/${name}" "$libDir/${name}"
    '') edcbLibs
  );

  enabledBonDrivers = lib.filterAttrs (_: drv: drv.enable) cfg.bonDrivers;

  resolveSoFile =
    name: drv: if drv.soFile != null then drv.soFile else "${drv.package}/lib/edcb/${name}.so";

  resolveIniFile =
    name: drv:
    if drv.iniFile != null then
      drv.iniFile
    else if drv.settings != null then
      pkgs.writeText "${name}.so.ini" (lib.generators.toINI { } drv.settings)
    else
      null;

  installBonDriver =
    name: drv:
    let
      iniFile = resolveIniFile name drv;
    in
    ''
      install -m 0644 ${lib.escapeShellArg (resolveSoFile name drv)} "$libDir/${name}.so"
    ''
    + lib.optionalString (iniFile != null) ''
      install -m 0644 ${lib.escapeShellArg iniFile} "$libDir/${name}.so.ini"
    ''
    + lib.optionalString (drv.chSet4File != null) ''
      install -m 0644 ${lib.escapeShellArg drv.chSet4File} "$settingDir/${name}(${drv.tunerName}).ChSet4.txt"
    '';

  installBonDrivers = lib.concatStringsSep "\n" (
    lib.mapAttrsToList installBonDriver enabledBonDrivers
  );

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

    rm -rf "$httpPublicDir"
    ln -sfn "$packageHttpPublicDir" "$httpPublicDir"

    if [ ! -e "$settingDir/HttpPublic.ini" ]; then
      install -m 0644 "$packageSettingDir/HttpPublic.ini" "$settingDir/HttpPublic.ini"
    fi

    if [ ! -e "$settingDir/XCODE_OPTIONS.lua" ]; then
      install -m 0644 "$packageSettingDir/XCODE_OPTIONS.lua" "$settingDir/XCODE_OPTIONS.lua"
    fi

    if [ ! -e "${stateDir}/EpgTimerSrv.ini" ]; then
      install -m 0644 "${./EpgTimerSrv.ini}" "${stateDir}/EpgTimerSrv.ini"
    fi

    ${postCommandSetup}

    ${linkEdcbLibs}

    # 宣言から外した BonDriver が残らないよう、管理対象の BonDriver_* を一旦消す
    rm -f "$libDir"/BonDriver_*

    ${installBonDrivers}

    ${lib.optionalString (cfg.bonDriver.chSet5File != null) ''
      install -m 0644 "${cfg.bonDriver.chSet5File}" "$settingDir/ChSet5.txt"
    ''}
  '';

  iniValueType = lib.types.oneOf [
    lib.types.bool
    lib.types.int
    lib.types.float
    lib.types.str
  ];

  bonDriverModule =
    { name, ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "この BonDriver を配置します。";
        };

        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
          description = ''
            BonDriver を含むパッケージ。`soFile` が未指定の場合、
            `''${package}/lib/edcb/${name}.so` を使用します。
          '';
        };

        soFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "BonDriver 本体 (.so) のパス。指定した場合は `package` より優先されます。";
        };

        settings = lib.mkOption {
          type = lib.types.nullOr (lib.types.attrsOf (lib.types.attrsOf iniValueType));
          default = null;
          example = {
            GLOBAL = {
              PRIORITY = 8;
            };
          };
          description = "`${name}.so.ini` の内容 (INI 形式に変換されます)。`iniFile` とは同時に指定できません。";
        };

        iniFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "`${name}.so.ini` としてそのまま配置するファイル。`settings` とは同時に指定できません。";
        };

        tunerName = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "PT3";
          description = ''
            BonDriver が返すチューナー名。ChSet4.txt のファイル名
            `${name}(<tunerName>).ChSet4.txt` に使用します。`chSet4File` 指定時は必須です。
          '';
        };

        chSet4File = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "ChSet4.txt として配置するファイル。";
        };
      };
    };
in
{
  options.services.edcb = {
    enable = lib.mkEnableOption "EDCB (EpgTimerSrv) サービスを有効化します。";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${system}.edcb;
      defaultText = lib.literalExpression "self.packages.${system}.edcb";
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

    postRecEndCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "録画終了後に実行するコマンド。";
    };

    postAddReserveCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "録画予約を追加したときに実行するコマンド。";
    };

    postChgReserveCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "録画予約を変更したときに実行するコマンド。";
    };

    postRecStartCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "録画を開始したときに実行するコマンド。";
    };

    postNotifyCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "更新通知が送られたときに実行するコマンド。";
    };

    bonDrivers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule bonDriverModule);
      default = { };
      example = lib.literalExpression ''
        {
          BonDriver_LinuxMirakc_T = {
            package = pkgs.bondriver_linuxmirakc;
            settings.GLOBAL.PRIORITY = 9;
            tunerName = "LinuxMirakc";
            chSet4File = ./BonDriver_LinuxMirakc_T.ChSet4.txt;
          };
        }
      '';
      description = ''
        EDCB に配置する BonDriver。属性名が BonDriver 名 (`BonDriver_` で始まる、拡張子なし) になります。
      '';
    };

    bonDriver.chSet5File = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "ChSet5.txtのパス。";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.concatLists (
      lib.mapAttrsToList (name: drv: [
        {
          assertion = lib.hasPrefix "BonDriver_" name;
          message = "services.edcb.bonDrivers.${name}: BonDriver 名は `BonDriver_` で始まる必要があります。";
        }
        {
          assertion = drv.soFile != null || drv.package != null;
          message = "services.edcb.bonDrivers.${name}: `package` か `soFile` のどちらかを指定してください。";
        }
        {
          assertion = !(drv.settings != null && drv.iniFile != null);
          message = "services.edcb.bonDrivers.${name}: `settings` と `iniFile` は同時に指定できません。";
        }
        {
          assertion = drv.chSet4File == null || drv.tunerName != null;
          message = "services.edcb.bonDrivers.${name}: `chSet4File` を指定する場合は `tunerName` も指定してください。";
        }
      ]) enabledBonDrivers
    );

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
