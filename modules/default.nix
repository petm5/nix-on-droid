# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{
  config ? null
, extraSpecialArgs ? { }
, pkgs ? import <nixpkgs> { }
, pkgsBootstrap ? (import (import ../lib/flake-inputs.nix).nixpkgs-for-bootstrap {
    crossSystem = pkgs.stdenv.hostPlatform.system;
    localSystem = "x86_64-linux";
  })
, home-manager-path ? <home-manager>
}:

let

  defaultConfigFile = "${builtins.getEnv "HOME"}/.config/nixpkgs/nix-on-droid.nix";

  configModule =
    if config != null then config
    else if builtins.pathExists defaultConfigFile then defaultConfigFile
    else pkgs.config.nix-on-droid or (throw "No config file found! Create one in ~/.config/nixpkgs/nix-on-droid.nix");

  overlayModule = {
    nixpkgs.overlays = [
      (self: super: {
        inherit pkgsBootstrap;
      })
      (import ../pkgs)
    ] ++ (import ../overlays);
  };

  eval = import ../lib/eval-config.nix {
    system = null;
    specialArgs = {
      inherit home-manager-path;
      initialModulesPath = pkgs.path + "/nixos/modules";
    } // extraSpecialArgs;
    modules = [ configModule overlayModule ];
    inherit pkgs;
    inherit (pkgs) lib;
  };

in

{
  inherit (eval) pkgs config options;

  inherit (eval.config.build) activationPackage;
}
