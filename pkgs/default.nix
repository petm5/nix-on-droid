# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{ pkgs }:

let

  crossPkgsStatic = pkgs.pkgsStatic.pkgsLLVM.appendOverlays [
    (self: super: {
      stdenv = super.withCFlags [ "-funroll-loops" "-O3" "-mcpu=cortex-a76" "-fomit-frame-pointer" ] super.stdenv;
    })
    (self: super: {
      talloc = crossPkgsStatic.callPackage ./talloc { };

      prootTermux = crossPkgsStatic.callPackage ./proot-termux { };
    })
  ];

in

{
  inherit (crossPkgsStatic) talloc prootTermux;
}
