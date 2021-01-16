{ config, pkgs, ... }:

{
  nix = {
    trustedUsers = ["lblasc"];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lblasc = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" ]; # Enable ‘sudo’ for the user.
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAncAa2+3hm+k1stfkAR1o+CfPP4UQV7UJClaWA8OC1/"
    ];
  };
}
