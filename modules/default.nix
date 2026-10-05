# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{
  config ? null
, extraSpecialArgs ? { }
, pkgs ? import <nixpkgs> { }
, nixpkgs-for-bootstrap ? (import ../lib/flake-inputs.nix).nixpkgs-for-bootstrap
, bootstrapSystem ? "x86_64-linux"
, home-manager-path ? <home-manager>
}:

let

  defaultConfigFile = "${builtins.getEnv "HOME"}/.config/nixpkgs/nix-on-droid.nix";

  configModule =
    if config != null then config
    else if builtins.pathExists defaultConfigFile then defaultConfigFile
    else pkgs.config.nix-on-droid or (throw "No config file found! Create one in ~/.config/nixpkgs/nix-on-droid.nix");

  eval = import ../lib/eval-config.nix {
    system = null;
    specialArgs = {
      inherit home-manager-path nixpkgs-for-bootstrap;
      initialModulesPath = pkgs.path + "/nixos/modules";
    } // extraSpecialArgs;
    modules = [ configModule ];
    extraModules = [ {
      nixpkgs.bootstrapSystem.system = bootstrapSystem;
    } ];
    inherit pkgs;
    inherit (pkgs) lib;
  };

in

{
  inherit (eval) pkgs config options;

  inherit (eval.config.build) activationPackage;
}
