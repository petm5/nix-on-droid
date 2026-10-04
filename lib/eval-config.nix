# Copyright (c) 2026, see AUTHORS. Licensed under MIT License, see LICENSE.

# Inspired by
# https://github.com/NixOS/nixpkgs/blob/master/nixos/lib/eval-config.nix
# (Copyright (c) 2003-2026 Eelco Dolstra and the Nixpkgs/NixOS contributors,
#  licensed under MIT License as well)

{
  system ? builtins.currentSystem,
  pkgs ? null,
  baseModules ? import ../modules/module-list.nix,
  specialArgs ? { },
  modules,
  prefix ? [ ],
  lib,
  extraModules ? [ ],
}:

with lib;

let
  pkgsModule = rec {
    _file = ./eval-config.nix;
    key = _file;
    config = lib.mkMerge (
      (optional (system != null) {
        nixpkgs.system = lib.mkDefault system;
      })
      ++ (optional (pkgs != null) {
        nixpkgs.pkgs = pkgs;
      })
    );
  };

  noUserModules = evalModules {
    inherit prefix specialArgs;
    modules =
      baseModules
      ++ extraModules
      ++ [
        pkgsModule
      ];
    class = "nixOnDroid";
  };

  nodWithUserModules = noUserModules.extendModules { modules = modules; };

  failedAssertions = map (x: x.message) (filter (x: !x.assertion) nodWithUserModules.config.assertions);

  module =
    if failedAssertions != [ ]
    then throw "\nFailed assertions:\n${concatMapStringsSep "\n" (x: "- ${x}") failedAssertions}"
    else showWarnings nodWithUserModules.config.warnings nodWithUserModules;
in

{
  inherit (module._module.args) pkgs;
  inherit (module) config options;
}
