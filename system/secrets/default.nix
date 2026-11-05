{ ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      "proxy_node/user" = { };
      "proxy_node/password" = { };
      "proxy_node/host" = { };
    };
  };
}
