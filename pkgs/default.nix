# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{ pkgs, crossPkgs }:

let

  crossPkgsStatic = crossPkgs.pkgsStatic.pkgsLLVM.appendOverlays [
    (self: super: {
      talloc = crossPkgsStatic.callPackage ./talloc { };

      prootTermux = crossPkgsStatic.callPackage ./proot-termux { };
    })
  ];

in

{
  inherit (crossPkgsStatic) talloc prootTermux;
}
