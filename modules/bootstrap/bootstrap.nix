# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{ config, bash, prootTermux, closureInfo, runCommand, extraPaths ? [] }:
let
  closure = closureInfo {
    rootPaths = [ config.build.activationPackage ] ++ extraPaths;
  };
in

runCommand "bootstrap" { } ''
  mkdir --parents $out/{.l2s,bin,dev/shm,etc,root,tmp,usr/{bin,lib}}
  mkdir --parents $out/nix/var/nix/{profiles,gcroots}/per-user/nix-on-droid

  mkdir --parents $out/nix/store
  xargs --arg-file ${closure}/store-paths cp --recursive --reflink=auto --target-directory $out/nix/store
  chmod --recursive u+w $out/nix

  ln --symbolic ${bash}/bin/sh $out/bin/sh

  install -D -m 0755 ${prootTermux}/bin/proot-static $out/bin/proot-static

  cp ${config.environment.files.login} $out/bin/login
  cp ${config.environment.files.loginInner} $out/usr/lib/login-inner

  ${bash}/bin/bash ${../environment/etc/setup-etc.sh} $out/etc ${config.build.activationPackage}/etc

  cp --dereference --recursive $out/etc/static $out/etc/.static.tmp
  rm $out/etc/static
  mv $out/etc/.static.tmp $out/etc/static

  find $out -executable -type f -printf '%P\n' > $out/EXECUTABLES.txt

  find $out -type l -printf '%l←%P\n' -delete > $out/SYMLINKS.txt
''
