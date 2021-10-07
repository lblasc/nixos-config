{ lib
, vscode-utils
, fetchFromGitHub
, sumneko-lua-language-server
}:
let
  version = "2.4.1";

  languageServer = sumneko-lua-language-server.overrideAttrs (old: {
    inherit version;

    ninjaFlags = [
      "-fcompile/ninja/linux.ninja"
    ];

    src = fetchFromGitHub {
      owner = "sumneko";
      repo = "lua-language-server";
      rev = "70335a4";
      sha256 = "1zmzf6ycmpgk4girb0kjlg12k5mdbhxzkjvkyr756mjik3zcf626";
      fetchSubmodules = true;
    };

  });
in
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "Lua";
    publisher = "sumneko";
    inherit version;
    sha256 = "0syvxmsakcxf4f4fqzbyfsipkk8hrhgcc92fhhbydm9azai9bfl8";
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
