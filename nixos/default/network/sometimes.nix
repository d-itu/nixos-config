{
  pkgs,
  lib,
  config,
  ...
}:
{
  sops.templates =
    let
      formatToml = pkgs.formats.toml { };
      upstream =
        config.networking.proxy.nodes
        |> builtins.attrValues
        |> builtins.filter (node: node.protocol == "naive")
        |> builtins.head;
    in
    {
      "sometimes.toml" = lib.mkIf config.services.sometimes.enable {
        file = formatToml.generate "sometimes.toml" {
          outbound_mark = config.services.sometimes.outboundMark;

          listeners = [
            {
              host = "127.0.0.1";
              port = config.services.sometimes.tproxyPort;
              protocol = "tproxy";
            }
            {
              host = "::1";
              port = config.services.sometimes.tproxyPort;
              protocol = "tproxy";
            }
          ];
          log.level = "info";
          upstream = with upstream; {
            inherit host password;
            username = user;
          };
          routing = {
            default = "proxy";
            rules = [
              {
                domain_suffix = [
                  "cn"
                  "noctalia.dev"
                ];
                action = "direct";
              }
              {
                domain = [ "dns.alidns.com" ];
                action = "direct";
              }
            ];
          };
          dns = {
            enabled = true;
            timeout_ms = 5000;
            bootstrap = [
              "119.29.29.29:53"
              "223.5.5.5:53"
            ];
            listen = [
              "127.0.0.1:1053"
              "[::1]:1053"
            ];
            upstreams = [
              {
                name = "cloudflare";
                protocol = "tcp";
                host = "1.1.1.1";
              }
              {
                name = "alidns";
                protocol = "udp";
                host = "dns.alidns.com";
              }
            ];
            routing = {
              rules = [
                {
                  domain_suffix = [ "cn" ];
                  upstream = "alidns";
                }
              ];
              default = "cloudflare";
            };
          };
        };
        owner = "sometimes";
        group = "sometimes";
      };
    };
}
