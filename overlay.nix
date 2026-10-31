final: prev:
let
  # AviSynthCUDAFilters は CUDA カーネルを PTX のみで埋め込み、実行時にドライバの
  # ptxas で JIT する。ドライバは自身より新しいツールキットが生成した PTX を JIT できず
  # CUDA error 222 (unsupported PTX version) になるため、nixpkgs 同梱の NVIDIA ドライバ
  # (R595 = CUDA 13.2) が追従できるツールキットに固定する。
  # 既定の cudaPackages (13.4 = PTX ISA 9.4 / R615 必須) はドライバが未追従。
  cudaPackages = final.cudaPackages_13_2;
in
{
  # apps
  akebi = final.callPackage ./packages/apps/akebi { };
  amatsukaze = final.callPackage ./packages/apps/amatsukaze { };
  amatsukaze-add-task = final.callPackage ./packages/apps/amatsukaze-add-task { };
  amatsukaze-native = final.callPackage ./packages/apps/amatsukaze-native { };
  amatsukaze-script-command = final.callPackage ./packages/apps/amatsukaze-script-command { };
  amatsukaze-server-cli = final.callPackage ./packages/apps/amatsukaze-server-cli { };
  amatsukaze-webui = final.callPackage ./packages/apps/amatsukaze-webui { };
  chapter_exe = final.callPackage ./packages/apps/chapter_exe { };
  danmaku2ass = final.callPackage ./packages/apps/danmaku2ass { };
  edcb = final.callPackage ./packages/apps/edcb { };
  edcb-material-webui = final.callPackage ./packages/apps/edcb-material-webui { };
  isdbscanner = final.callPackage ./packages/apps/isdbscanner { };
  join_logo_scp = final.callPackage ./packages/apps/join_logo_scp { };
  konomitv = final.callPackage ./packages/apps/konomitv { };
  konomitv-client = final.callPackage ./packages/apps/konomitv-client { };
  mirakurun = final.callPackage ./packages/apps/mirakurun { };
  recisdb = final.callPackage ./packages/apps/recisdb { };

  # avisynth
  avisynthcudafilters = final.callPackage ./packages/avisynth/avisynthcudafilters {
    inherit cudaPackages;
  };
  avisynthplus-cuda = final.callPackage ./packages/avisynth/avisynthplus-cuda {
    inherit cudaPackages;
  };
  masktools = final.callPackage ./packages/avisynth/masktools { };
  mvtools = final.callPackage ./packages/avisynth/mvtools { };
  nnedi3 = final.callPackage ./packages/avisynth/nnedi3 { };
  rgtools = final.callPackage ./packages/avisynth/rgtools { };
  tivtc = final.callPackage ./packages/avisynth/tivtc { };
  yadifmod2 = final.callPackage ./packages/avisynth/yadifmod2 { };

  # encoders
  nvenc = final.callPackage ./packages/encoders/nvenc {
    inherit cudaPackages;
  };
  qsvenc = final.callPackage ./packages/encoders/qsvenc { };
  qsvenc-legacy = final.callPackage ./packages/encoders/qsvenc-legacy { };

  # python (KonomiTV dependencies resolved via uv2nix; usable standalone)
  ariblib = final.callPackage ./packages/python/ariblib { };

  # ts
  b24tovtt = final.callPackage ./packages/ts/b24tovtt { };
  psisiarc = final.callPackage ./packages/ts/psisiarc { };
  psisimux = final.callPackage ./packages/ts/psisimux { };
  tsreadex = final.callPackage ./packages/ts/tsreadex { };
  tsreplace = final.callPackage ./packages/ts/tsreplace { };

  # tuners
  bondriver_linuxmirakc = final.callPackage ./packages/tuners/bondriver_linuxmirakc { };
  ifd-px4 = final.callPackage ./packages/tuners/ifd-px4 { };
  it930x-firmware = final.callPackage ./packages/tuners/it930x-firmware { };
  px4_drv = final.callPackage ./packages/tuners/px4_drv { };
}
