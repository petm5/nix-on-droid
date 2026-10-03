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

    assertions = [{
      assertion = builtins.elem pkgs.stdenv.hostPlatform.system [ "aarch64-linux" "x86_64-linux" ];
      message = "${pkgs.stdenv.hostPlatform.system} is not supported; aarch64-linux / x86_64-linux " +
        "are the only currently supported system types";
    }];

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
