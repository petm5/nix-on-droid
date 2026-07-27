{ config, pkgs, ... }: {
  imports = [ ../build/initial-build.nix ];

  system.stateVersion = "24.05";

  # Fix invoking bash after initial build.
  user.shell = "${pkgs.bash}/bin/bash";

  build = {
    channel = {
      nixpkgs = builtins.getEnv "NIXPKGS_CHANNEL_URL";
      nix-on-droid = builtins.getEnv "NIX_ON_DROID_CHANNEL_URL";
    };

    flake.nix-on-droid = builtins.getEnv "NIX_ON_DROID_FLAKE_URL";
  };

  system.build.bootstrap = pkgs.callPackage ./bootstrap.nix { inherit config; };

  system.build.bootstrapZip = pkgs.callPackage ./bootstrap-zip.nix { inherit (config.system.build) bootstrap; };
}
