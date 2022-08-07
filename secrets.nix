let
  max = (import ./users/max/userinfo.nix null).sshKeys;
  hosts = import ./hosts;
  systemKeys = x: x.ssh.id.publicKey or null;
in with hosts;
{
  "cluster/services/dns/pdns-admin-oidc-secrets.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "cluster/services/dns/pdns-admin-salt.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "cluster/services/dns/pdns-admin-secret.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "cluster/services/dns/pdns-api-key.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "cluster/services/dns/pdns-db-credentials.age".publicKeys = max ++ map systemKeys [ VEGAS prophet ];
  "cluster/services/patroni/passwords/replication.age".publicKeys = max ++ map systemKeys [ VEGAS prophet ];
  "cluster/services/patroni/passwords/rewind.age".publicKeys = max ++ map systemKeys [ VEGAS prophet ];
  "cluster/services/patroni/passwords/superuser.age".publicKeys = max ++ map systemKeys [ VEGAS prophet ];
  "cluster/services/wireguard/mesh-keys/VEGAS.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "cluster/services/wireguard/mesh-keys/prophet.age".publicKeys = max ++ map systemKeys [ prophet ];
  "secrets/acme-dns-key.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/coturn-static-auth.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/gitlab-initial-root-password.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/gitlab-openid-secret.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/gitlab-runner-registration.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/gitlab-secret-db.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/gitlab-secret-jws.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/gitlab-secret-otp.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/gitlab-secret-secret.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/grafana-secrets.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/hci-cache-config.age".publicKeys = max ++ map systemKeys [ VEGAS prophet ];
  "secrets/hci-cache-credentials-prophet.age".publicKeys = max ++ map systemKeys [ prophet ];
  "secrets/hci-cache-credentials-VEGAS.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/hci-token-prophet.age".publicKeys = max ++ map systemKeys [ prophet ];
  "secrets/hci-token-VEGAS.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/hydra-bincache.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/hydra-builder-key.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/hydra-db-credentials.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/hydra-s3.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/hyprspace-key-VEGAS.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/hyprspace-key-prophet.age".publicKeys = max ++ map systemKeys [ prophet ];
  "secrets/ipfs-swarm-key.age".publicKeys = max ++ map systemKeys [ VEGAS prophet ];
  "secrets/keycloak-dbpass.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/matrix-appservice-discord-token.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/minio-root-credentials.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/nextcloud-adminpass.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/nextcloud-dbpass.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/oauth2_proxy-secrets.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/postfix-ldap-mailboxes.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/searxng-secrets.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/sips-db-credentials.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/synapse-db.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/synapse-keys.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/synapse-ldap.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/synapse-turn.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/wireguard-key-storm-VEGAS.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/wireguard-key-wgautobahn.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "secrets/wireguard-key-wgmv.age".publicKeys = max ++ map systemKeys [ VEGAS ];
}
