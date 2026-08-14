{
  description = "Nix-enabled environment for your Android device";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    # for bootstrap zip ball creation and proot-termux builds, we use a fixed version of nixpkgs to ease maintanence.
    # head of nixos-25.11 as of 2026-02-16
    nixpkgs-for-bootstrap.url = "github:NixOS/nixpkgs/fa56d7d6de78f5a7f997b0ea2bc6efd5868ad9e8";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-formatter-pack = {
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nmd.follows = "nmd";
    };

    nixpkgs-docs.url = "github:NixOS/nixpkgs/release-23.05";

    nmd = {
      url = "sourcehut:~rycee/nmd";
      inputs.nixpkgs.follows = "nixpkgs-docs";
    };

    droidctl = {
      url = "github:t184256/droidctl";
      inputs.nixpkgs.follows = "nixpkgs-docs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-for-bootstrap, home-manager, nix-formatter-pack, nmd, nixpkgs-docs, droidctl }:
    let
      forEachSystem = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];

      overlay = nixpkgs.lib.composeManyExtensions (import ./overlays);

      formatterPackArgsFor = forEachSystem (system: {
        inherit nixpkgs system;
        checkFiles = [ ./. ];

        config.tools = {
          deadnix = {
            enable = true;
            noLambdaPatternNames = true;
          };
          nixpkgs-fmt.enable = true;
          statix.enable = true;
        };
      });
    in
    {
      apps = forEachSystem (system: {
        default = self.apps.${system}.nix-on-droid;

        nix-on-droid = {
          type = "app";
          program = "${self.packages.${system}.nix-on-droid}/bin/nix-on-droid";
        };

        deploy = {
          type = "app";
          program = toString (import ./scripts/deploy.nix { inherit nixpkgs system; });
        };
      });

      checks = forEachSystem (system: {
        nix-formatter-pack-check = nix-formatter-pack.lib.mkCheck formatterPackArgsFor.${system};
      });

      formatter = forEachSystem (system: nix-formatter-pack.lib.mkFormatter formatterPackArgsFor.${system});

      lib.nixOnDroidConfiguration =
        { pkgs
        , modules ? [ ]
        , extraSpecialArgs ? { }
        , home-manager-path ? home-manager.outPath
          # deprecated:
        , config ? null
        , extraModules ? null
        , system ? null  # pkgs.stdenv.hostPlatform.system is used to detect user's arch
        , bootstrapSystem ? pkgs.stdenv.hostPlatform.system
        }: let
          crossPkgs = import nixpkgs-for-bootstrap {
            crossSystem = pkgs.stdenv.hostPlatform.system;
            localSystem = bootstrapSystem;
          };
        in
        if ! (builtins.elem pkgs.stdenv.hostPlatform.system [ "aarch64-linux" "x86_64-linux" ]) then
          throw
            ("${pkgs.stdenv.hostPlatform.system} is not supported; aarch64-linux / x86_64-linux " +
              "are the only currently supported system types")
        else
          pkgs.lib.throwIf
            (config != null || extraModules != null || system != null)
            ''
              The 'nixOnDroidConfiguration' arguments

              - 'config'
              - 'extraModules'
              - 'system'

              have been removed.
              Instead of 'extraModules' use the argument 'modules'.
              The 'system' will be inferred by 'pkgs.stdenv.hostPlatform.system',
              so pass a 'pkgs = import nixpkgs { system = "aarch64-linux"; };'
              See the 22.11 release notes for more.
            ''
            (import ./modules {
              inherit extraSpecialArgs home-manager-path pkgs crossPkgs;
              config.imports = modules;
            });

      overlays.default = overlay;

      packages = forEachSystem (system:
        let
          testScripts = [
            "android_integration"
            "bootstrap_flakes"
            "bootstrap_channels"
            "poke_around"
            "test_channels_uiautomator"
            "test_channels_shell"
          ];


          optionalEnv = envVar:
            let
              envValue = builtins.getEnv envVar;
            in
            pkgs.lib.mkIf
              (envValue != "")
              (envValue);

          perArchBootstrapNodConfig = arch: extraModules:
            self.lib.nixOnDroidConfiguration {
              pkgs = import nixpkgs-for-bootstrap {
                system = "${arch}-linux";
              };
              bootstrapSystem = system;
              modules = [
                ./modules/bootstrap
                ./modules/build/initial-build.nix
                {
                  system.stateVersion = "24.05";

                  build = {
                    channel = {
                      nixpkgs = optionalEnv "NIXPKGS_CHANNEL_URL";
                      nix-on-droid = optionalEnv "NIX_ON_DROID_CHANNEL_URL";
                    };

                    flake.nix-on-droid = optionalEnv "NIX_ON_DROID_FLAKE_URL";
                  };
                }
              ] ++ extraModules;
            };

          flattenArch = arch: derivationAttrset:
            nixpkgs.lib.attrsets.mapAttrs'
              (name: drv:
                nixpkgs.lib.attrsets.nameValuePair (name + "-" + arch) drv
              )
              derivationAttrset;
          perArchCustomPkgs = arch: flattenArch arch
            (let
              nodConfig = perArchBootstrapNodConfig arch [];
            in {
              inherit (nodConfig.pkgs) talloc prootTermux;
              inherit (nodConfig.config.system.build) bootstrap bootstrapZip;
            });

          pkgs = nixpkgs.legacyPackages.${system};

          arch = pkgs.stdenv.hostPlatform.parsed.cpu.name;

          nixpkgsChannel = pkgs.releaseTools.channel {
            name = "nixpkgs";
            src = nixpkgs;
          };
          nodChannel = pkgs.releaseTools.channel {
            name = "nix-on-droid";
            src = self;
            isNixOS = false;
          };

          testNodConfig = perArchBootstrapNodConfig arch [{
            build = {
              channel = {
                nixpkgs = "file://${nixpkgsChannel}/tarballs/nixexprs.tar.xz";
                nix-on-droid = "file://${nodChannel}/tarballs/nixexprs.tar.xz";
              };

              flake = {
                nixpkgs = "path:${nixpkgs}";
                nix-on-droid = "path:${self}";
              };
            };

            image.bootstrap.storePaths = [ self nixpkgs nixpkgsChannel nodChannel ];
          }];
          testScriptRunner = name: pkgs.callPackage ./tests/emulator {
            inherit (droidctl.packages.${system}) droidctl;
            bootstrapZip = "${testNodConfig.config.system.build.bootstrapZip}/bootstrap-${arch}.zip";
            testScriptName = name;
          };
          testSuite = builtins.listToAttrs
            (map
              (name:
                nixpkgs.lib.attrsets.nameValuePair ("integrationTest-" + name)
                  (testScriptRunner name)
              )
              testScripts
            );

          docs = import ./docs {
            inherit home-manager;
            pkgs = nixpkgs-docs.legacyPackages.${system};
            nmdSrc = nmd;
          };
        in
        {
          nix-on-droid = pkgs.callPackage ./nix-on-droid { };
          testMatrixJson = pkgs.writeText "test-matrix.json" (
            builtins.toJSON testScripts
          );
          allTestDerivations = pkgs.linkFarm "all-nix-on-droid-tests" (
            nixpkgs.lib.mapAttrsToList (name: drv: { inherit name; path = drv; }) testSuite
          );
        }
        // testSuite
        // (perArchCustomPkgs "aarch64")
        // (perArchCustomPkgs "x86_64")
        // docs
      );

      templates = {
        default = self.templates.minimal;

        minimal = {
          path = ./templates/minimal;
          description = "Minimal example of Nix-on-Droid system config.";
        };

        home-manager = {
          path = ./templates/home-manager;
          description = "Minimal example of Nix-on-Droid system config with home-manager.";
        };

        advanced = {
          path = ./templates/advanced;
          description = "Advanced example of Nix-on-Droid system config with home-manager.";
        };
      };
    };
}
