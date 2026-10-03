# Copyright (c) 2019-2026, see AUTHORS. Licensed under MIT License, see LICENSE.

# Non-flake entrypoint stub, invoked by nix-on-droid build / switch

{
  config ? null
, extraSpecialArgs ? { }
, pkgs ? import <nixpkgs> {}
, home-manager-path ? <home-manager>
}:

let

  defaultConfigFile = "${builtins.getEnv "HOME"}/.config/nixpkgs/nix-on-droid.nix";

  configModule =
    if config != null then config
    else if builtins.pathExists defaultConfigFile then defaultConfigFile
    else pkgs.config.nix-on-droid or (throw "No config file found! Create one in ~/.config/nixpkgs/nix-on-droid.nix");

  flakeInputs = import ../lib/flake-inputs.nix;

  eval = import ../lib/eval-config.nix {
    system = null;
    specialArgs = {
      inherit home-manager-path;
      inherit (flakeInputs) nixpkgs-for-bootstrap;
      modulesPath = "${pkgs.path}/nixos/modules";
    } // extraSpecialArgs;
    baseModules = import ./module-list.nix;
    modules = [ configModule ];
    extraModules = [ {
      nixpkgs.bootstrapSystem.system = "x86_64-linux";
    } ];
    inherit pkgs;
    inherit (pkgs) lib;
  };

in

{
  inherit (eval) pkgs config options;

  inherit (eval.config.build) activationPackage;
}
