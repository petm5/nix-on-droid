{ config, lib, pkgs, ... }:
{
  options.image.bootstrap = {
    storePaths = lib.mkOption {
      type = with lib.types; listOf path;
      default = [ ];
      description = "The store paths to include in the bootstrap zipball.";
    };
    compress = lib.mkEnableOption "compress the bootstrap zipball" // {
      default = true;
    };
  };

  config = {
    system.build.bootstrap = pkgs.callPackage ./bootstrap.nix {
      inherit config;
      extraPaths = config.image.bootstrap.storePaths;
    };

    system.build.bootstrapZip = pkgs.streamZip {
      contents = config.system.build.bootstrap;
      inherit (config.image.bootstrap) compress;
    };
  };
}
