tools: {
  ssh.id = with tools.dns; {
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZ4FyGi69MksEn+UJZ87vw1APqiZmPNlEYIr0CbEoGv";
    hostNames = subResolve "prophet" "node";
  };

  interfaces = {
    primary = {
      addr = "10.0.0.92";
      addrPublic = "152.67.76.138";
      link = "enp0s3";
    };
  };

#  hypr = {
#    id = "";
#    addr = "10.100.3.9";
#  };

  enterprise = {
    subdomain = "node";
  };

  arch = "aarch64";
  nixos = import ./system.nix;
}
