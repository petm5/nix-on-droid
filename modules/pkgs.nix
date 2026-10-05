{ config, pkgs, lib, nixpkgs-for-bootstrap, ... }:
let

  cfg = config.nixpkgs.bootstrapSystem;

in {

  options = {
    nixpkgs.bootstrapSystem = lib.mkOption {
      type = lib.types.attrs;
      default = config.nixpkgs.system;
      description = "Specifies the platform on which the bootstrap binaries should be built.";
    };
  };

  config = {

    nixpkgs.overlays = [
      (self: super: {
        pkgsBootstrap = import nixpkgs-for-bootstrap {
          crossSystem = pkgs.stdenv.hostPlatform.system;
          localSystem = cfg.system;
        };
      })
      (import ../pkgs)
    ];

  };

}
