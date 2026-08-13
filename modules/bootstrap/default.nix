{ config, lib, pkgs, ... }:
{
  options.image.bootstrap = {
    storePaths = lib.mkOption {
      type = with lib.types; listOf path;
      default = [ ];
      description = "The store paths to include in the bootstrap zipball.";
    };
  };

  config = {
    system.build.bootstrap = pkgs.callPackage ./bootstrap.nix {
      inherit config;
      extraPaths = config.image.bootstrap.storePaths;
    };

    system.build.bootstrapZip = pkgs.callPackage ./bootstrap-zip.nix { inherit (config.system.build) bootstrap; };
  };
}
