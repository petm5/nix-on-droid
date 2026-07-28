{ androidenv
, android-tools
, droidctl
, bootstrapZip
, writeShellApplication
, testScriptName
, targetArch
}:
let
  emulatorScript = androidenv.emulateApp {
    name = "nix-on-droid-emulator";
    platformVersion = "29";
    abiVersion = if targetArch == "x86_64" then "x86_64"
      else if targetArch == "aarch64" then "arm64-v8a"
      else throw "Unsupported architecture ${targetArch}";
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
    export BOOTSTRAP_ZIP="${bootstrapZip}/bootstrap-${targetArch}.zip"
    exec ${./run-emulator.sh}
  '';
}
