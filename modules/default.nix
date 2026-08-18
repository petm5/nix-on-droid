# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{
  config ? null
, extraSpecialArgs ? { }
, pkgs ? import <nixpkgs> { }
, crossPkgs ? import ./get-cross-pkgs.nix { inherit pkgs; }
, home-manager-path ? <home-manager>
}:

with pkgs.lib;

let
  defaultConfigFile = "${builtins.getEnv "HOME"}/.config/nixpkgs/nix-on-droid.nix";

  configModule =
    if config != null then config
    else if builtins.pathExists defaultConfigFile then defaultConfigFile
    else pkgs.config.nix-on-droid or (throw "No config file found! Create one in ~/.config/nixpkgs/nix-on-droid.nix");

  overlayModule = {
    nixpkgs.overlays = [
      (self: super:
        import ../pkgs {
          pkgs = super;
          inherit crossPkgs;
        }
      )
    ] ++ (import ../overlays);
  };

  nodModules = import ./module-list.nix {
    inherit pkgs home-manager-path;
  };

  rawModule = evalModules {
    modules = [ configModule overlayModule ] ++ nodModules;
    specialArgs = extraSpecialArgs;
    class = "nixOnDroid";
  };

  failedAssertions = map (x: x.message) (filter (x: !x.assertion) rawModule.config.assertions);

  module =
    if failedAssertions != [ ]
    then throw "\nFailed assertions:\n${concatMapStringsSep "\n" (x: "- ${x}") failedAssertions}"
    else showWarnings rawModule.config.warnings rawModule;
in

{
  inherit (module.config.build) activationPackage;
  inherit (module._module.args) pkgs;
  inherit (module) config options;
}
