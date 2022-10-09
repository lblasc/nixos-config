{ lib
, vscode-utils
, fetchFromGitHub
, sumneko-lua-language-server
}:
# switch to upstream package
# see: https://github.com/NixOS/nixpkgs/pull/195186
let
  version = languageServer.version;

  languageServer = sumneko-lua-language-server;
in
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "Lua";
    publisher = "sumneko";
    inherit version;
    sha256 = "sha256-Unzs9rX/0MlQprSvScdBCCFMeLCaGzWsMbcFqSKY2XY=";
  };

  postInstall = ''
    # don't run chmod in store
    sed -i '/fs.promises.chmod/d' $out/$installPrefix/client/out/languageserver.js

    # extension comes with prebuild language server
    rm -f $out/$installPrefix/server/bin/lua-language-server
    ln -s ${languageServer}/bin/lua-language-server $out/$installPrefix/server/bin/lua-language-server
  '';

  meta = {
    license = lib.licenses.mit;
  };
}
