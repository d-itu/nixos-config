{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    services.cockpit_server = {
      enable = lib.mkEnableOption "server of pi_remote cockpit";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.cockpit_server;
      };
      listenStream = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/.cockpit/cockpit-server.sock";
      };
    };
  };
  config =
    let
      cfg = config.services.cockpit_server;
    in
    {
      systemd.user = lib.mkIf cfg.enable {
        services.cockpit_server = {
          Service = {
            ExecStart = "${cfg.package}/bin/cockpit_server --socket ${cfg.listenStream}";
          };
        };
        sockets.cockpit_server = {
          Socket = {
            ListenStream = cfg.listenStream;
          };
          Install = {
            WantedBy = [ "sockets.target" ];
          };
        };
      };
    };
}
