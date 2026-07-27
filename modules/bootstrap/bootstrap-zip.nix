# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{ lib, stdenv, runCommand, zip, bootstrap }:

let
  targetSystem = stdenv.hostPlatform.system;
  arch = lib.strings.removeSuffix "-linux" targetSystem;
in
runCommand "bootstrap-zip" { } ''
  mkdir $out
  cd ${bootstrap}
  ${zip}/bin/zip -q -9 -r $out/bootstrap-${arch} ./* ./.l2s
''
