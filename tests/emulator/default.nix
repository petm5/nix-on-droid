{ stdenv
, androidenv
, android-tools
, droidctl
, bootstrapZip
, writeShellApplication
, testScriptName
, fetchurl
}:
let
  package = "com.termux.nix";
  revision = "188037";

  abiVersion = if stdenv.isx86_64 then "x86_64"
    else if stdenv.isAarch64 then "arm64-v8a"
    else throw "Unsupported architecture ${stdenv.hostPlatform.system}";

  apkFile = fetchurl {
    url = "https://f-droid.org/repo/${package}_${revision}.apk";
    hash = "sha256-D2uoLWkpbDPGbuXRCqGEY+SVPCpsP9EOfneMLNrgMwM=";
  };

  emulatorScript = androidenv.emulateApp {
    name = "nix-on-droid-emulator";
    platformVersion = "29";
    systemImageType = "default";
    inherit package abiVersion;
    app = apkFile;
    androidEmulatorFlags = "-no-snapshot-save -no-window -no-audio -camera-back none -partition-size 8192";
  };
in
writeShellApplication {
  name = "run-nix-on-droid-tests";
  runtimeInputs = [ android-tools droidctl ];
  text = ''
    export EMULATOR_LAUNCH_SCRIPT="${emulatorScript}/bin/run-test-emulator"
    export TEST_SCRIPT="${testScriptName}"
    export BOOTSTRAP_ZIP_SCRIPT="${bootstrapZip}/bin/bootstrap-zip"
    export BOOTSTRAP_ZIP_FILE="bootstrap-${stdenv.hostPlatform.parsed.cpu.name}.zip"
    exec ${./run-emulator.sh}
  '';
}
