{ lib
, vscode-utils
, fetchFromGitHub
, sumneko-lua-language-server
}:
let
  version = "1.15.0";

  languageServer = sumneko-lua-language-server.overrideAttrs (old: {
    inherit version;

    src = fetchFromGitHub {
      owner = "sumneko";
      repo = "lua-language-server";
      rev = version;
      sha256 = "198vqk2xj8phal20nxp7h14harpfvmfl4ah63219izz8fy5rmfkc";
      fetchSubmodules = true;
    };

  });
in
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "Lua";
    publisher = "sumneko";
    inherit version;
    sha256 = "1sxk1qjv8izd373ny848n1n3sh9ij354bhckr29lszgj4f3s956n";
  };

  postInstall = ''
    # don't run chmod in store
    sed -i '/fs.chmodSync/d' $out/$installPrefix/client/out/languageserver.js

    # extension comes with prebuild language server
    rm -rf $out/$installPrefix/server/bin/Linux
    ln -s ${languageServer}/bin $out/$installPrefix/server/bin/Linux
  '';

  meta = {
    license = lib.licenses.mit;
  };
}
