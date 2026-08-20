# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{ writeShellApplication
, closureInfo
, zip
, findutils
}:

{ name ? "bootstrap"
, activationPackage
, extraPaths
, compress ? true
}:

let
  closure = closureInfo {
    rootPaths = [ activationPackage ] ++ extraPaths;
  };
in

writeShellApplication {
  runtimeInputs = [
    zip
    findutils
  ];

  name = "${name}-zip";

  text = ''
    out=$(mktemp -d)
    trap 'rm -r "$out"' EXIT

    mapfile -t store_paths < "${closure}"/store-paths

    (
      find "''${store_paths[@]}" -executable -type f -printf '%p\n'
      find "${activationPackage}"/filesystem -follow -executable -type f -printf '/%P\n'
    ) > "$out"/EXECUTABLES.txt

    (
      find "''${store_paths[@]}" -type l -printf '%l←%p\n'
      echo "${activationPackage}/etc←/etc/static"
      find "${activationPackage}"/etc/ -type l -printf '/etc/static/%P←/etc/%P\n'
    ) > "$out"/SYMLINKS.txt

    mkdir --parents "$out"/{.l2s,bin,dev/shm,etc,root,tmp,usr/{bin,lib}}
    mkdir --parents "$out"/nix/var/nix/{profiles,gcroots}/per-user/nix-on-droid

    find "${activationPackage}"/etc/ -type d | sed -e "s,^${activationPackage},$out," | xargs mkdir --parents

    cp --recursive --dereference --symbolic-link --no-preserve=mode --target-directory "$out" "${activationPackage}"/filesystem/*

    mkdir --parents "$out"/nix/store
    find "''${store_paths[@]}" ! -type l -type f -exec cp --parents --symbolic-link --no-preserve=mode --target-directory "$out" {} +

    (cd "$out" && find . | zip -q ${if compress then "-9" else "-0"} -@ -)
  '';
}
