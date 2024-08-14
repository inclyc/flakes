{ config, ... }:
{
  inclyc.services.rathole.enable = true;
  inclyc.services.rathole.configFile = config.sops.templates."rathole-server.toml".path;

  sops.secrets."rathole-ssh-token" = { };
  sops.secrets."rathole-hitmc-token" = { };
  sops.secrets."rathole-private-key" = { };

  sops.templates."rathole-server.toml".content = ''
    [server]
    bind_addr = "0.0.0.0:20155" # `2333` specifies the port that rathole listens for clients

    [server.transport]
    type = "noise"

    [server.transport.noise]
    # DVH4EM3P5phh5yzU7cOEDrDvdvahsiSSyeML+okHHx0=
    local_private_key = "${config.sops.placeholder.rathole-private-key}"

    [server.services.104-ssh]
    token = "${config.sops.placeholder.rathole-ssh-token}" # Token that is used to authenticate the client for the service. Change to an arbitrary value.
    bind_addr = "0.0.0.0:10179"

    [server.services.adrastea-ssh]
    token = "${config.sops.placeholder.rathole-ssh-token}" # Token that is used to authenticate the client for the service. Change to an arbitrary value.
    bind_addr = "0.0.0.0:20156"

    [server.services.luofan-ssh]
    token = "${config.sops.placeholder.rathole-ssh-token}" # Token that is used to authenticate the client for the service. Change to an arbitrary value.
    bind_addr = "0.0.0.0:10121"

    [server.services.hitmc-server]
    token = "${config.sops.placeholder.rathole-hitmc-token}"
    bind_addr = "0.0.0.0:20157"
  '';
}
