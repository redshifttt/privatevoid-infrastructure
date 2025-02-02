let
  tools = import ./lib/tools.nix;
  pins = import ./sources;
in with tools;
super: rec {
  dvc = patch (super.dvc.overrideAttrs (old: {
    propagatedBuildInputs = with super.python3Packages; old.propagatedBuildInputs ++ [
      aiobotocore
      boto3
      (s3fs.overrideAttrs (_: { postPatch = ''
          substituteInPlace requirements.txt \
            --replace "fsspec==2022.02.0" "fsspec" \
            --replace "aiobotocore~=2.1.0" "aiobotocore"
        '';
      }))
    ];
  })) "patches/base/dvc";

  hydra = (patch super.hydra-unstable "patches/base/hydra").override { nix = super.nixVersions.nix_2_8; };

  sssd = (super.sssd.override { withSudo = true; }).overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      ${super.removeReferencesTo}/bin/remove-references-to -t ${super.stdenv.cc.cc} $out/modules/ldb/memberof.so
    '';
    disallowedReferences = [ super.stdenv.cc.cc ];
  });

  jre17_standard = let
    jre = super.jre_minimal.override {
      jdk = super.jdk17_headless;
      modules = [
          "java.se"
          "jdk.naming.dns"
          "jdk.crypto.ec"
          "jdk.zipfs"
          "jdk.security.auth"
          "jdk.unsupported"
          "jdk.xml.dom"
          "jdk.sctp"
          "jdk.management"
          "jdk.dynalink"
      ];
    };
  in jre // { meta = jre.meta // { inherit (super.jdk17_headless.meta) platforms; }; };

  keycloak = super.keycloak.override {
    jre = jre17_standard;
  };

  prometheus-jitsi-exporter = patch super.prometheus-jitsi-exporter "patches/base/prometheus-jitsi-exporter";

  tempo = (super.tempo.override { buildGoModule = super.buildGo118Module; }).overrideAttrs (_: {
    version = builtins.substring 1 (-1) pins.tempo.version;
    src = super.npins.mkSource pins.tempo;
    subPackages = [ "cmd/tempo" ];
  });
}
