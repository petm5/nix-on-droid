# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

[
  ./build/activation.nix
  ./build/config.nix
  ./environment/android-integration.nix
  ./environment/etc
  ./environment/links.nix
  ./environment/login
  ./environment/network-interfaces.nix
  ./environment/nix.nix
  ./environment/path.nix
  ./environment/session-init.nix
  ./environment/shell.nix
  ./home-manager.nix
  ./nixos-components.nix
  ./terminal.nix
  ./time.nix
  ./upgrade.nix
  ./user.nix
  ./version.nix

  {
    _file = ./module-list.nix;
  }
]
