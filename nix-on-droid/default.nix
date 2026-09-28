# Copyright (c) 2019-2022, see AUTHORS. Licensed under MIT License, see LICENSE.

{
  lib,
  stdenvNoCC,
  makeBinaryWrapper,
  bash,
  coreutils,
  nix,
}:

stdenvNoCC.mkDerivation {
  name = "nix-on-droid";

  src = ./.;

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  installPhase = ''
    install -D -m755 ./nix-on-droid.sh $out/bin/nix-on-droid

    wrapProgram $out/bin/nix-on-droid \
      --set PATH ${lib.makeBinPath [
        bash
        coreutils
        nix
      ]}
  '';
}
