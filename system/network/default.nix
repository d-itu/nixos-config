{
  pkgs,
  config,
  ...
}:
{
  imports = [ ./sometimes ];
  services.sometimes = {
    enable = true;
    configFile = config.sops.templates."sometimes.toml".path;
  };

  services.dae = {
    enable = false;
    configFile = config.sops.templates."config.dae".path;
  };

  sops.templates =
    let
      ph = config.sops.placeholder;
      formatToml = pkgs.formats.toml { };
    in
    {
      "config.dae".content = builtins.readFile ./dae/config.dae + ''
        node {
          naive: 'https://${ph."proxy_node/user"}:${ph."proxy_node/password"}@${ph."proxy_node/host"}'
        }
      '';
      "sometimes.toml" = {
        content =
          formatToml.generate "sometimes.toml" {
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
            upstream = {
              host = ph."proxy_node/host";
              username = ph."proxy_node/user";
              password = ph."proxy_node/password";
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
          }
          |> builtins.readFile;
        owner = "sometimes";
        group = "sometimes";
      };
    };
}
