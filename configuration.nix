{ config, ... }@args:

let
  hostname = "x1";

  pkgs = import ./pkgs {
    config.allowUnfree = true;
  };

in (import "/etc/nixos/${hostname}/configuration.nix" (args // {
  pkgs = pkgs // {
    nixos-rebuild = pkgs.writeScriptBin "nixos-rebuild" ''
      #!${pkgs.stdenv.shell}
      nixpkgsSrc=$(nix-build /etc/nixos/pkgs -A nixpkgsSrc --no-out-link)
      exec ${config.system.build.nixos-rebuild}/bin/nixos-rebuild -I nixpkgs=$nixpkgsSrc $@
    '';
    nixos-niv = pkgs.writeScriptBin "nixos-niv" ''
      #!${pkgs.stdenv.shell}
      exec ${pkgs.niv}/bin/niv -s /etc/nixos/pkgs/sources.json $@
    '';
  };
}))
