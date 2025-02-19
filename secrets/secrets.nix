let
  system-homeserver1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL3hbWmccdfoYplE/PZ251CMUrCiTJJd9ON37/RR2JkP";
  robert-macmini = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILAWNw2z4swcjAkPPwO1evXclnlIYta1jaJKPKWsrOoo";
  robert-macbook-air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4GO2AYXejanlgjDDg3C9K2IG8WhB+Bp8up785b3IP5";
  robert = [
    robert-macmini
    robert-macbook-air
  ];
in
{
  "tailscale-homeserver1.age".publicKeys = [ system-homeserver1 ] ++ robert;
}
