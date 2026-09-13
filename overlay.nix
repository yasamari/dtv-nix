final: prev:
let
  isx86_64 = final.stdenv.hostPlatform.isx86_64;
in
{
  # apps
  akebi = final.callPackage ./packages/apps/akebi { };
  amatsukaze-add-task = final.callPackage ./packages/apps/amatsukaze-add-task { };
  amatsukaze = final.callPackage ./packages/apps/amatsukaze { };
  chapter_exe = final.callPackage ./packages/apps/chapter_exe { };
  edcb = final.callPackage ./packages/apps/edcb { };
  isdbscanner = final.callPackage ./packages/apps/isdbscanner { };
  join_logo_scp = final.callPackage ./packages/apps/join_logo_scp { };
  konomitv = final.callPackage ./packages/apps/konomitv {
    qsvenc = if isx86_64 then final.qsvenc else null;
    nvenc = if isx86_64 then final.nvenc else null;
  };
  konomitv-client = final.callPackage ./packages/apps/konomitv-client { };
  mirakurun = final.callPackage ./packages/apps/mirakurun { };
  recisdb = final.callPackage ./packages/apps/recisdb { };

  # avisynth
  avisynthcudafilters = final.callPackage ./packages/avisynth/avisynthcudafilters { };
  avisynthplus-cuda = final.callPackage ./packages/avisynth/avisynthplus-cuda { };
  masktools = final.callPackage ./packages/avisynth/masktools { };
  mvtools = final.callPackage ./packages/avisynth/mvtools { };
  nnedi3 = final.callPackage ./packages/avisynth/nnedi3 { };
  rgtools = final.callPackage ./packages/avisynth/rgtools { };
  tivtc = final.callPackage ./packages/avisynth/tivtc { };
  yadifmod2 = final.callPackage ./packages/avisynth/yadifmod2 { };

  # encoders
  nvenc = final.callPackage ./packages/encoders/nvenc { };
  qsvenc = final.callPackage ./packages/encoders/qsvenc { };
  qsvenc-legacy = final.callPackage ./packages/encoders/qsvenc-legacy { };

  # python (KonomiTV dependencies, usable standalone)
  aerich = final.callPackage ./packages/python/aerich { };
  ariblib = final.callPackage ./packages/python/ariblib { };
  asyncio-atexit = final.callPackage ./packages/python/asyncio-atexit { };
  atproto = final.callPackage ./packages/python/atproto { };
  biim = final.callPackage ./packages/python/biim { };
  grapheme = final.callPackage ./packages/python/grapheme { };
  hashids = final.callPackage ./packages/python/hashids { };
  pypika-tortoise = final.callPackage ./packages/python/pypika-tortoise { };
  tortoise-orm = final.callPackage ./packages/python/tortoise-orm { };
  zendriver = final.callPackage ./packages/python/zendriver { };

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
