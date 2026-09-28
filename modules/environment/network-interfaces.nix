{ config, lib, ... }:

let
  cfg = config.networking;
in

with lib;

{

  options.networking = {

    hostName = mkOption {
      default = "";
      type = lib.types.strMatching "^$|^[[:alnum:]]([[:alnum:]_-]{0,61}[[:alnum:]])?$";
    };

    domain = mkOption {
      default = null;
      type = types.nullOr types.str;
    };

    enableIPv6 = mkEnableOption "IPv6" // {
      default = true;
    };

    nameservers = mkOption {
      type = types.listOf types.str;
      default = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      description = ''
        The list of nameservers. Auto-detection from the host system is not supported.
      '';
    };

  };

  config = {

    environment.etc = {
      "resolv.conf".text = concatLines (map (address: "nameserver ${address}") cfg.nameservers);
    };

  };

}
