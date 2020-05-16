self: super: {
  vscode-extensions = super.vscode-extensions // {
    sumneko.Lua = super.callPackage ./pkgs/misc/vscode-extensions/lua.nix { };
    rust-lang.rust = super.vscode-utils.extensionsFromVscodeMarketplace [{
      name = "rust";
      publisher = "rust-lang";
      version = "0.7.6";
      sha256 = "11shih93gvph829sgsq88xp70h7ccj574w278xh1ynihqh4gcb2l";
    }];
  };
}
