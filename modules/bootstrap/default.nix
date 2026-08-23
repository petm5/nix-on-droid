{ config, lib, pkgs, ... }:
{
  options.image.bootstrap = {
    compress = lib.mkEnableOption "compress the bootstrap zipball" // {
      default = true;
    };
  };

  config = {
    system.build.bootstrapZip = pkgs.streamZip {
      inherit (config.build) activationPackage;
      inherit (config.image.bootstrap) compress;
    };
  };
}
