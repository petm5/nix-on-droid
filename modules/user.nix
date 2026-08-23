# Copyright (c) 2019-2022, see AUTHORS. Licensed under MIT License, see LICENSE.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.user;

  idsDerivation = pkgs.runCommandLocal "ids.nix" { } ''
    cat > $out <<EOF
    {
      gid = $(${pkgs.coreutils}/bin/id -g);
      uid = $(${pkgs.coreutils}/bin/id -u);
    }
    EOF
  '';

  ids = import idsDerivation;

  toShellPath = shell:
    if lib.types.shellPackage.check shell then
      "${shell}${shell.shellPath}"
    else if lib.types.package.check shell then
      throw "${shell} is not a shell package"
    else
      shell;
in

{

  ###### interface

  options = {

    user = {
      group = mkOption {
        type = types.str;
        default = "nix-on-droid";
        description = "Group name.";
      };

      gid = mkOption {
        type = types.int;
        default = ids.gid;
        defaultText = "$(id -g)";
        description = ''
          Gid.  This value should not be set manually except you know what you are doing.
        '';
      };

      home = mkOption {
        type = types.path;
        readOnly = true;
        description = "Path to home directory.";
      };

      shell = mkOption {
        type = types.coercedTo types.path toShellPath (types.either types.shellPackage (types.passwdEntry types.path));
        default = pkgs.bashInteractive;
        description = "Path to login shell.";
      };

      userName = mkOption {
        type = types.str;
        default = "nix-on-droid";
        description = "User name.";
      };

      uid = mkOption {
        type = types.int;
        default = ids.uid;
        defaultText = "$(id -u)";
        description = ''
          Uid.  This value should not be set manually except you know what you are doing.
        '';
      };
    };

  };


  ###### implementation

  config = {

    environment.etc = {
      "group".text = ''
        root:x:0:
        ${cfg.group}:x:${toString cfg.gid}:${cfg.userName}
      '';

      "passwd".text = ''
        root:x:0:0:System administrator:${config.build.installationDir}/root:/bin/sh
        ${cfg.userName}:x:${toString cfg.uid}:${toString cfg.gid}:${cfg.userName}:${cfg.home}:${cfg.shell}
      '';
    };

    user = {
      home = "/data/data/com.termux.nix/files/home";
    };

  };

}
