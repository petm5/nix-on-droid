{ config, pkgs, ... }:
{
  system.build.bootstrap = pkgs.callPackage ./bootstrap.nix { inherit config; };

  system.build.bootstrapZip = pkgs.callPackage ./bootstrap-zip.nix { inherit (config.system.build) bootstrap; };
}
