{ lib
, vscode-utils
, lua-language-server
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "lua";
    publisher = "sumneko";
    version = "3.6.19";
    sha256 = "sha256-7f8zovJS1lNwrUryxgadrBbNRw/OwFqry57JWKY1D8E=";
  };

  postInstall = ''
    ln -sf ${lua-language-server}/bin/lua-language-server \
      $out/$installPrefix/server/bin/lua-language-server

    # running chmod in runtime is not needed and it won't work if the binary is in nix store
    sed -i '/fs.promises.chmod/d' $out/$installPrefix/client/out/languageserver.js
  '';

  meta = {
    description = "The Lua language server provides various language features for Lua to make development easier and faster.";
    homepage = "https://marketplace.visualstudio.com/items?itemName=sumneko.lua";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.lblasc ];
  };
}
