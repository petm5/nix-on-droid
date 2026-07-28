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
  apkFile = fetchurl {
    url = "https://nix-on-droid.unboiled.info/com.termux.nix_188035-x86_64.apk";
    hash = "sha256-Vy9O+dgHSzIn9O1DZgjrrBGEs9pI8D/zvm85OqiV/1E=";
  };

  emulatorScript = androidenv.emulateApp {
    name = "nix-on-droid-emulator";
    platformVersion = "29";
    abiVersion = if stdenv.isx86_64 then "x86_64"
      else if stdenv.isAarch64 then "arm64-v8a"
      else throw "Unsupported architecture ${stdenv.hostPlatform.system}";
    systemImageType = "default";
    app = apkFile;
    package = "com.termux.nix";
    androidEmulatorFlags = "-no-window -no-audio -no-boot-anim -gpu swiftshader_indirect";
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
