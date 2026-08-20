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
    system.build.bootstrapZip = pkgs.streamZip {
      inherit (config.build) activationPackage;
      extraPaths = config.image.bootstrap.storePaths;

      inherit (config.image.bootstrap) compress;
    };
  };
}
