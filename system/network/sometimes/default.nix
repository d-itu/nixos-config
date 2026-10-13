{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sometimes;
  nft = "${pkgs.nftables}/bin/nft";
  ip = "${pkgs.iproute2}/bin/ip";
  mark = toString cfg.outboundMark;
  rules = pkgs.writeText "sometimes-rules.nft" ''
    table inet sometimes {
      chain output {
        type route hook output priority mangle; policy accept;
        meta mark ${mark} return
        meta l4proto != tcp return
        tcp dport 53 return
        fib daddr type local return
        ip daddr { 0.0.0.0/8, 10.0.0.0/8, 127.0.0.0/8, 169.254.0.0/16, 172.16.0.0/12, 192.168.0.0/16, 224.0.0.0/4, 240.0.0.0/4 } return
        ip6 daddr { ::/128, ::1/128, fc00::/7, fe80::/10, ff00::/8 } return
        meta mark set 0x5354
      }

      chain prerouting {
        type filter hook prerouting priority mangle; policy accept;
        meta mark 0x5354 meta l4proto tcp tproxy to :${toString cfg.tproxyPort} accept
      }
    }

    table inet sometimes_dns {
      chain output {
        type nat hook output priority dstnat; policy accept;
        meta mark ${mark} return
        udp dport 53 redirect to :1053
        tcp dport 53 redirect to :1053
      }
    }
  '';
  networkUp = pkgs.writeShellScript "sometimes-network-up" ''
    ${ip} -4 route add local 0.0.0.0/0 dev lo table 100 || true
    ${ip} -6 route add local ::/0 dev lo table 100 || true
    ${ip} -4 rule add priority 100 fwmark 0x5354 lookup 100 || true
    ${ip} -6 rule add priority 100 fwmark 0x5354 lookup 100 || true
    ${nft} -f ${rules} || true
  '';
  networkDown = pkgs.writeShellScript "sometimes-network-down" ''
    ${nft} delete table inet sometimes_dns || true
    ${nft} delete table inet sometimes || true
    ${ip} -6 rule del priority 100 fwmark 0x5354 lookup 100 || true
    ${ip} -4 rule del priority 100 fwmark 0x5354 lookup 100 || true
    ${ip} -6 route del local ::/0 dev lo table 100 || true
    ${ip} -4 route del local 0.0.0.0/0 dev lo table 100 || true
  '';
in
{
  options.services.sometimes = {
    enable = lib.mkEnableOption "host-local TCP TPROXY and DNS interception";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.sometimes;
      description = "The packaged sometimes executable.";
    };
    configFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/sometimes/sometimes.toml";
      description = "Absolute path to the private TOML configuration outside the Nix store.";
    };
    outboundMark = lib.mkOption {
      type = lib.types.int;
      default = 21327;
    };
    tproxyPort = lib.mkOption {
      type = lib.types.int;
      default = 12345;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.configFile && !(lib.hasPrefix "/nix/store/" cfg.configFile);
        message = "services.sometimes.configFile must be an absolute path outside the Nix store";
      }
    ];
    users.groups.sometimes = { };
    users.users.sometimes = {
      isSystemUser = true;
      group = "sometimes";
    };

    systemd.services.sometimes = {
      description = "Sometimes TPROXY client";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        User = "sometimes";
        Group = "sometimes";
        ExecStart = "${cfg.package}/bin/sometimes run --config ${cfg.configFile}";
        ExecStartPre = "${cfg.package}/bin/sometimes check --config ${cfg.configFile}";
        ExecStartPost = "+${networkUp}";
        ExecStop = "+${networkDown}";
        ExecStopPost = "+${networkDown}";
        AmbientCapabilities = "CAP_NET_ADMIN";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        UMask = "0077";
        Restart = "on-failure";
        RestartSec = "3s";
      };
    };
  };
}
