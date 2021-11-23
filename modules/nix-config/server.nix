{ pkgs, lib, config, inputs, ... }:
let
  fixPriority = x: if config.services.hydra.enable
  then lib.mkForce x
  else x;
in {
  nix = {
    package = inputs.nix-super.defaultPackage.${pkgs.system};

    trustedUsers = [ "root" "@wheel" "@admins" ];

    extraOptions = fixPriority ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
      flake-registry = ${
        pkgs.writeText "null-registry.json" ''{"flakes":[],"version":2}''
      }
    '';

    binaryCaches = [ "https://cache.privatevoid.net" ];
    binaryCachePublicKeys = [ "cache.privatevoid.net:SErQ8bvNWANeAvtsOESUwVYr2VJynfuc9JRwlzTTkVg=" ];

    autoOptimiseStore = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
