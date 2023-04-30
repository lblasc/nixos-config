self: super: {
  xerox-workcentre-3045b-3045ni = super.callPackage_i686 ./pkgs/xerox-workcentre-3045b-3045ni { };
  vscode-extensions = super.vscode-extensions // {
    sumneko.lua = super.callPackage ./pkgs/misc/vscode-extensions/lua.nix { };
  };

}
