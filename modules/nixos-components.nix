{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/misc/assertions.nix")
    (modulesPath + "/system/build.nix")
    (modulesPath + "/security/ca.nix")
    (modulesPath + "/config/networking.nix")
    (modulesPath + "/misc/nixpkgs.nix")
    (modulesPath + "/config/nix-flakes.nix")
  ];
}
