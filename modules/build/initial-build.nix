# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{ config, lib, pkgs, ... }:

with lib;

let
  defaultNixpkgsBranch = "nixos-24.05";
  defaultNixOnDroidBranch = "release-24.05";

  defaultNixpkgsChannel = "https://nixos.org/channels/${defaultNixpkgsBranch}";
  defaultNixOnDroidChannel = "https://github.com/nix-community/nix-on-droid/archive/${defaultNixOnDroidBranch}.tar.gz";

  defaultNixpkgsFlake = "github:NixOS/nixpkgs/${defaultNixpkgsBranch}";
  defaultNixOnDroidFlake = "github:nix-community/nix-on-droid/${defaultNixOnDroidBranch}";

  normalizeFlake = val: if isString val then val else "path:${val}";
in

{

  ###### interface

  options = {

    build = {
      channel = mkOption {
        type = with types; attrsOf (either str package);
        description = "Mapping of channel names to either remote URLs or local derivations to be linked directly.";
      };

      flake = mkOption {
        type = with types; attrsOf (coercedTo package normalizeFlake str);
        description = "Mapping of flake inputs to either path references or local derivations. Derivations will be normalized to a `path:/nix/store/...` flake reference.";
      };
    };

  };


  ###### implementation

  config = {

    build = {
      initialBuild = true;

      channel = {
        nixpkgs = mkDefault defaultNixpkgsChannel;
        nix-on-droid = mkDefault defaultNixOnDroidChannel;
      };

      flake = {
        nixpkgs = mkDefault defaultNixpkgsFlake;
        nix-on-droid = mkDefault defaultNixOnDroidFlake;
      };
    };

    # /etc/group and /etc/passwd need to be build on target machine because
    # uid and gid need to be determined.
    environment.etc = {
      "group".enable = false;
      "passwd".enable = false;
      "UNINTIALISED".text = "";
    };

  };

}
