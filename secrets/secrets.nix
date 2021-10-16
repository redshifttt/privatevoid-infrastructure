let
  max = (import ../users/max/userinfo.nix null).sshKeys;
  hosts = import ../hosts;
  systemKeys = x: x.ssh.id.publicKey or null;
in with hosts;
{
  "discourse-adminpass.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "discourse-dbpass.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "hydra-s3.age".publicKeys = max ++ map systemKeys [ styx ];
  "hydra-db-credentials.age".publicKeys = max ++ map systemKeys [ styx ];
  "gitea-db-credentials.age".publicKeys = max ++ map systemKeys [ git ];
  "oauth2_proxy-secrets.age".publicKeys = max ++ map systemKeys [ VEGAS ];
  "wireguard-key-wgautobahn.age".publicKeys = max ++ map systemKeys [ VEGAS ];
}
