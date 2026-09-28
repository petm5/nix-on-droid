{ pkgs }:

let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  nodeName = lock.nodes.root.inputs.flake-compat;
  flake = (import (
    fetchTarball {
      url =
        lock.nodes.${nodeName}.locked.url
          or "https://github.com/NixOS/flake-compat/archive/${lock.nodes.${nodeName}.locked.rev}.tar.gz";
      sha256 = lock.nodes.${nodeName}.locked.narHash;
    }
  ) { src = ../.; }).defaultNix;
  nixpkgs = flake.inputs.nixpkgs-for-bootstrap;
in
import nixpkgs {
  crossSystem = pkgs.stdenv.hostPlatform.system;
  localSystem = "x86_64-linux";
}
