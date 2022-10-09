{ config, pkgs, ... }:

{
  nix = {
    #package = pkgs.nixVersions.unstable;
    settings.trusted-users = [ "lblasc" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.warn-dirty = false;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lblasc = {
    isNormalUser = true;
    extraGroups = [ "wheel" config.users.groups.keys.name ]; # Enable ‘sudo’ for the user.
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAncAa2+3hm+k1stfkAR1o+CfPP4UQV7UJClaWA8OC1/"
    ];
  };

  environment.systemPackages = with pkgs; [
    bat
    git
    htop
    niv
    screen
    vim
    wget
    wireguard-tools
  ];

  programs = {
    vim.defaultEditor = true;
  };
}
