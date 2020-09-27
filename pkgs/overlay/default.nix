self: super: {
  vscode-extensions = super.vscode-extensions // {
    sumneko.Lua = super.callPackage ./pkgs/misc/vscode-extensions/lua.nix { };
    HashiCorp.terraform = super.callPackage ./pkgs/misc/vscode-extensions/terraform.nix { };
  };
}
