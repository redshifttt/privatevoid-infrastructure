{ aspect, config, hosts, lib, pkgs, tools, ... }:
with tools.nginx;
let
  inherit (tools.meta) domain;
  cfg = config.services.ipfs;
  gw = config.links.ipfsGateway;
in
{
  imports = [
    aspect.modules.ipfs
  ];

  systemd.services.ipfs = {
    serviceConfig = {
      LimitNOFILE = 524288;
      IOSchedulingPriority = 7;
    };
    environment = {
      OTEL_TRACES_EXPORTER = "otlp";
      OTEL_EXPORTER_OTLP_PROTOCOL = "grpc";
      OTEL_EXPORTER_OTLP_ENDPOINT = config.links.tempo-otlp-grpc.url;
      OTEL_TRACES_SAMPLER = "parentbased_traceidratio";
      OTEL_TRACES_SAMPLER_ARG = "0.01";
    };
  };

  systemd.slices.remotefshost.sliceConfig = {
    IOWeight = 5;
    IOReadIOPSMax = [ 
      "/dev/sda 100"
      "/dev/sdb 100"
    ];
    IOWriteIOPSMax = [ 
      "/dev/sda 100"
      "/dev/sdb 100"
    ];
    IODeviceLatencyTargetSec = [ 
      "/dev/sda 500ms"
      "/dev/sdb 500ms"
    ];
  };

  users.users.nginx.extraGroups = [ cfg.group ];

  services.nginx.virtualHosts = {
    "top-level.${domain}".locations = {
      "~ ^/ip[fn]s" = {
        proxyPass = gw.url;
        extraConfig = ''
          add_header X-Content-Type-Options "";
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };

    "lain-ipfs.${domain}" = vhosts.basic // {
      locations = {
        "= /".return = "404";
        "~ ^/ip[fn]s" = {
          proxyPass = gw.url;
          extraConfig = ''
            add_header X-Content-Type-Options "";
            add_header Access-Control-Allow-Origin *;
          '';
        };
        "/ipfs".extraConfig = "expires max;";
      };
    };
    "ipfs.admin.${domain}" = vhosts.basic // {
      locations."/api".proxyPass = "http://unix:/run/ipfs/ipfs-api.sock:";
      locations."/ipns/webui.ipfs.${domain}".proxyPass = "${gw.url}/ipns/webui.ipfs.${domain}";
      locations."= /".return = "302 /ipns/webui.ipfs.${domain}";
      locations."/debug/metrics/prometheus" = {
        proxyPass = "http://unix:/run/ipfs/ipfs-api.sock:";
        extraConfig = ''
          access_log off;
          auth_request off;
          allow ${hosts.VEGAS.interfaces.primary.addr};
          deny all;
        '';
      };
    };
  };
  services.oauth2_proxy.nginx.virtualHosts = [ "ipfs.admin.${domain}" ];

  security.acme.certs."ipfs.${domain}" = {
    domain = "*.ipfs.${domain}";
    extraDomainNames = [ "*.ipns.${domain}" ];
    dnsProvider = "pdns";
    group = "nginx";
  };

  services.nginx.virtualHosts."ipfs.${domain}" = vhosts.basic // {
    serverName = "~^(.+)\.(ip[fn]s)\.${domain}$";
    enableACME = false;
    useACMEHost = "ipfs.${domain}";
    locations = {
      "/" = {
        proxyPass = gw.url;
        extraConfig = ''
          add_header X-Content-Type-Options "";
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };
  };
}
