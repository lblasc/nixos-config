{ config, ... }:
let
  pkgs = import ./pkgs {
    config.allowUnfree = true;
  };

  hostname = builtins.readFile ./hostname;

  nixos-rebuild = pkgs.writeScriptBin "nixos-rebuild" ''
    #!${pkgs.stdenv.shell}
    nixpkgsSrc=$(nix-build /etc/nixos/pkgs -A nixpkgsSrc --no-out-link)
    exec ${config.system.build.nixos-rebuild}/bin/nixos-rebuild -I nixpkgs=$nixpkgsSrc $@
  '';

  nixos-niv = pkgs.writeScriptBin "nixos-niv" ''
    #!${pkgs.stdenv.shell}
    exec ${pkgs.niv}/bin/niv -s /etc/nixos/pkgs/sources.json $@
  '';
in
{
  imports =
    [
      "/etc/nixos/${hostname}/configuration.nix"
      "${pkgs.sources.sops-nix}/modules/sops"
      ./common.nix
    ];

  nixpkgs.pkgs = pkgs;

  nix = {
    nixPath = [
      "nixpkgs=${pkgs.nixpkgsSrc}"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
  };

  environment.systemPackages = with pkgs; [
    nixos-niv
    nixos-rebuild
  ];
}
