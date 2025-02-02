{ pkgs, inputs, lib, hosts, config, ... }:
let
  inherit (config.networking) hostName;
  inherit (inputs.self.packages.${pkgs.system}) hyprspace;
  hyprspaceCapableNodes = lib.filterAttrs (_: host: host ? hypr) hosts;
  peersFormatted = builtins.mapAttrs (_: x: { "${x.hypr.addr}".id = x.hypr.id; }) hyprspaceCapableNodes;
  peersFiltered = lib.filterAttrs (name: _: name != hostName) peersFormatted;
  peerList = lib.foldAttrs (n: _: n) null (builtins.attrValues peersFiltered);
  myNode = hosts.${hostName};
  listenPort = myNode.hypr.listenPort or 8001;

  routes' = map (x: lib.genAttrs (x.hypr.routes or []) (_: { ip = x.hypr.addr; })) (builtins.attrValues hyprspaceCapableNodes);
  routes = builtins.foldl' (x: y: x // y) {} (lib.flatten routes');

  interfaceConfig = pkgs.writeText "hyprspace.yml" (builtins.toJSON {
    interface = {
      name = "hyprspace";
      listen_port = listenPort;
      inherit (myNode.hypr) id;
      address = "${myNode.hypr.addr}/24";
      private_key = "@HYPRSPACEPRIVATEKEY@";
    };
    peers = peerList;
    inherit routes;
  });

  privateKeyFile = config.age.secrets.hyprspace-key.path;
  runConfig = "/run/hyprspace.yml";
in {
  networking.hosts = lib.mapAttrs' (k: v: lib.nameValuePair v.hypr.addr [k "${k}.hypr"]) hyprspaceCapableNodes;
  age.secrets.hyprspace-key = {
    file = ../../secrets/hyprspace-key- + "${hostName}.age";
    mode = "0400";
  };
  systemd.services.hyprspace = {
    enable = true;
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      test -e ${runConfig} && rm ${runConfig}
      cp ${interfaceConfig} ${runConfig}
      chmod 0600 ${runConfig}
      ${pkgs.replace-secret}/bin/replace-secret '@HYPRSPACEPRIVATEKEY@' "${privateKeyFile}" ${runConfig}
      chmod 0400 ${runConfig}
    '';
    environment.HYPRSPACE_SWARM_KEY = config.age.secrets.ipfs-swarm-key.path;
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
      ExecStart = "${hyprspace}/bin/hyprspace up hyprspace -f -c ${runConfig}";
      ExecStop = "${hyprspace}/bin/hyprspace down hyprspace";
      IPAddressDeny = [
        "10.0.0.0/8"
        "100.64.0.0/10"
        "169.254.0.0/16"
        "172.16.0.0/12"
        "192.0.0.0/24"
        "192.0.2.0/24"
        "192.168.0.0/16"
        "198.18.0.0/15"
        "198.51.100.0/24"
        "203.0.113.0/24"
        "240.0.0.0/4"
        "100::/64"
        "2001:2::/48"
        "2001:db8::/32"
        "fc00::/7"
        "fe80::/10"
      ];
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ listenPort ];
    allowedUDPPorts = [ listenPort ];
    trustedInterfaces = [ "hyprspace" ];
  };
}
