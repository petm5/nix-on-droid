{ initialModulesPath, ... }: {
  imports = [
    (initialModulesPath + "/misc/assertions.nix")
    (initialModulesPath + "/system/build.nix")
    (initialModulesPath + "/security/ca.nix")
    (initialModulesPath + "/config/networking.nix")
    (initialModulesPath + "/misc/nixpkgs.nix")
    (initialModulesPath + "/config/nix-flakes.nix")
  ];
}
