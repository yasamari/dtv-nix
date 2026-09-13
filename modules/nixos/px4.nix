{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.px4;

  system = pkgs.stdenv.hostPlatform.system;

  px4_drv = cfg.package.override {
    kernel = config.boot.kernelPackages.kernel;
  };
in
{
  options.hardware.px4 = {
    enable = lib.mkEnableOption "px4_drvを有効化します。";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${system}.px4_drv;
      defaultText = lib.literalExpression "self.packages.${system}.px4_drv";
      description = "使用するpx4_drvパッケージ。";
    };

    it930xFirmwarePackage = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${system}.it930x-firmware;
      defaultText = lib.literalExpression "self.packages.${system}.it930x-firmware";
      description = "使用するit930x-firmwareパッケージ。";
    };

    ifdPx4Package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${system}.ifd-px4;
      defaultText = lib.literalExpression "self.packages.${system}.ifd-px4";
      description = "使用するifd-px4パッケージ。";
    };

    cardReader.enable = lib.mkEnableOption "チューナーのカードリーダーを有効化します。" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.firmware = [ cfg.it930xFirmwarePackage ];
    boot.extraModulePackages = [ px4_drv ];
    services.udev.packages = [ px4_drv ];

    services.pcscd = lib.mkIf cfg.cardReader.enable {
      enable = true;
      plugins = [ cfg.ifdPx4Package ];
    };
  };
}
