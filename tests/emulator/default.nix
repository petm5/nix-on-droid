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
  revision = "188035";

  abiVersion = if stdenv.isx86_64 then "x86_64"
    # else if stdenv.isAarch64 then "arm64-v8a"
    else throw "Unsupported architecture ${stdenv.hostPlatform.system}";

  hashes = {
    "x86_64" = "sha256-Vy9O+dgHSzIn9O1DZgjrrBGEs9pI8D/zvm85OqiV/1E=";
    # "arm64-v8a" = "";
  };

  apkFile = fetchurl {
    url = "https://nix-on-droid.unboiled.info/${package}_${revision}-${abiVersion}.apk";
    hash = hashes.${abiVersion};
  };

  emulatorScript = androidenv.emulateApp {
    name = "nix-on-droid-emulator";
    platformVersion = "29";
    systemImageType = "default";
    inherit package abiVersion;
    app = apkFile;
    androidEmulatorFlags = "-no-snapshot-save -no-window -no-audio -camera-back none";
  };
in
writeShellApplication {
  name = "run-nix-on-droid-tests";
  runtimeInputs = [ android-tools droidctl ];
  text = ''
    export EMULATOR_BIN="${emulatorScript}/bin/run-test-emulator"
    export TEST_SCRIPT="${testScriptName}"
    export BOOTSTRAP_ZIP="${bootstrapZip}"
    exec ${./run-emulator.sh}
  '';
}
