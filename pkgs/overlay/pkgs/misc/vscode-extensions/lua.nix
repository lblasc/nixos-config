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
      rev = "77bf688";
      sha256 = "19ag78xfi7hrjzhsimizd3ma8m2ic2dbh20i3z3zxlqgnf06kagk";
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
