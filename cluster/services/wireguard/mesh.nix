{ cluster, config, ... }:
let
  inherit (config.networking) hostName;

  link = cluster.config.links."mesh-node-${hostName}";

  mkPeer = peerName: let
    peerLink = cluster.config.links."mesh-node-${peerName}";
  in {
    publicKey = peerLink.extra.pubKey;
    allowedIPs = [ "${peerLink.extra.meshIp}/32" ] ++ peerLink.extra.extraRoutes;
    endpoint = peerLink.tuple;
  };
  extraPeers = [
    {
      publicKey = "Veol/Yw5Nf3eZVSGynLZIuR2kvnyGynexzQ8GhdDQWo=";
      allowedIPs = [ "10.1.1.151/32" ];
      endpoint = "pve-etcd-node-fb2465761cf3ce658e6b410bbcf1f2db.fly.dev:51280";
    }
  ];
in
{
  age.secrets.wireguard-key-core = {
    file = link.extra.privKeyFile;
    mode = "0400";
  };

  networking = {
    firewall = {
      trustedInterfaces = [ "wgmesh" ];
      allowedUDPPorts = [ link.port ];
    };

    wireguard = {
      enable = true;
      interfaces.wgmesh = {
        ips = [ "${link.extra.meshIp}/24" ];
        listenPort = link.port;
        privateKeyFile = config.age.secrets.wireguard-key-core.path;
        peers = map mkPeer cluster.config.services.wireguard.otherNodes.mesh ++ extraPeers;
      };
    };
  };
}
