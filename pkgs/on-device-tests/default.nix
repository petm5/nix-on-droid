{
  writeShellApplication,
  bash,
  coreutils,
  nix,
  nix-on-droid,
  bats,
  ncurses,
  gnugrep,
  findutils,
}:

writeShellApplication {
  name = "on-device-tests";

  runtimeInputs = [
    bash
    coreutils
    nix
    nix-on-droid
    bats
    ncurses
    gnugrep
    findutils
  ];

  text = ''
    export CHANNEL_DIR="${../..}"
    export ON_DEVICE_TESTS_DIR="${../../tests/on-device}"
    export FLAKE_URL="path:$CHANNEL_DIR"
    export ON_DEVICE_TESTS_SETUP=1

    cd "$ON_DEVICE_TESTS_DIR" && exec bash .run.sh
  '';
}
