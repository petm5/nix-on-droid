{ stdenv
, androidenv
, android-tools
, droidctl
, bootstrapZip
, writeShellApplication
, testScriptName
}:
let
  emulatorScript = androidenv.emulateApp {
    name = "nix-on-droid-emulator";
    platformVersion = "29";
    abiVersion = if stdenv.isx86_64 then "x86_64"
      else if stdenv.isAarch64 then "arm64-v8a"
      else throw "Unsupported architecture ${stdenv.hostPlatform.system}";
    systemImageType = "default";
    # app = ./MyApp.apk;
    # package = "MyApp";
    # activity = "MainActivity";
    # androidEmulatorFlags = "-no-window -no-audio -no-boot-anim -gpu swiftshader_indirect";
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
