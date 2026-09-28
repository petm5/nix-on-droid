# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{ pkgs
, home-manager-path
}:

[
  ./build/activation.nix
  (pkgs.path + "/nixos/modules/misc/assertions.nix")
  (pkgs.path + "/nixos/modules/system/build.nix")
  ./build/config.nix
  ./environment/android-integration.nix
  (pkgs.path + "/nixos/modules/security/ca.nix")
  ./environment/etc
  ./environment/links.nix
  ./environment/login
  (pkgs.path + "/nixos/modules/config/networking.nix")
  ./environment/network-interfaces.nix
  ./environment/nix.nix
  (pkgs.path + "/nixos/modules/misc/nixpkgs.nix")
  (pkgs.path + "/nixos/modules/config/nix-flakes.nix")
  ./environment/path.nix
  ./environment/session-init.nix
  ./environment/shell.nix
  ./home-manager.nix
  ./terminal.nix
  ./time.nix
  ./upgrade.nix
  ./user.nix
  ./version.nix

  {
    _file = ./module-list.nix;
    _module.args = {
      inherit home-manager-path;
    };
    nixpkgs.pkgs = pkgs.lib.mkDefault pkgs;
  }
]
