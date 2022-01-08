{ lib
, vscode-utils
, fetchFromGitHub
, sumneko-lua-language-server
}:
let
  version = languageServer.version;

  languageServer = sumneko-lua-language-server;
in
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "Lua";
    publisher = "sumneko";
    inherit version;
    sha256 = "sha256-cnH2DqbCECupWoEm0ThXpihQ1zcR/LpP9HmmI44wC8w=";
  };

  postInstall = ''
    # don't run chmod in store
    sed -i '/fs.chmodSync/d' $out/$installPrefix/client/out/languageserver.js

    # extension comes with prebuild language server
    rm -f $out/$installPrefix/server/bin/lua-language-server
    ln -s ${languageServer}/bin/lua-language-server $out/$installPrefix/server/bin/lua-language-server
  '';

  meta = {
    license = lib.licenses.mit;
  };
}
