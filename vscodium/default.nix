{ config, lib, pkgs, ... }:

let
  inherit (pkgs.vscode-utils) buildVscodeMarketplaceExtension;
  extensions = (with pkgs.vscode-extensions; [
      bbenoist.Nix
      ms-python.python
      ms-vscode-remote.remote-ssh
      vscodevim.vim
      redhat.vscode-yaml
    ]);

  sumneko.Lua = import ./lua.nix { inherit pkgs; };

  vscodium-with-extensions = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = extensions ++ [ sumneko.Lua ];
  };
in {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    vscodium-with-extensions
  ];
}
