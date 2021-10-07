self: super: {
  vscode-extensions = super.vscode-extensions // {
    sumneko.Lua = super.callPackage ./pkgs/misc/vscode-extensions/lua.nix { };
  };

  xerox-workcentre-3045b-3045ni = super.callPackage_i686 ./pkgs/xerox-workcentre-3045b-3045ni { };
}
