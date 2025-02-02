{ aspect, inputs, config, hosts, pkgs, ... }:

{
  imports =
    [
      # Hardware
      ./hardware-configuration.nix

      ./modules/nginx
      inputs.agenix.nixosModules.age

      ./services/cdn-shield
      ./services/meet
      ./services/reflex
      aspect.modules.hercules-ci-agent
      aspect.modules.hyprspace
      aspect.modules.ipfs
      aspect.modules.nix-builder
      aspect.modules.sss


    ]
    ++ aspect.sets.server;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "prophet";
  networking.nameservers = [ hosts.VEGAS.interfaces.vstub.addr ];

  time.timeZone = "Europe/Zurich";

  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;

  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;

  system.stateVersion = "21.11";

}

