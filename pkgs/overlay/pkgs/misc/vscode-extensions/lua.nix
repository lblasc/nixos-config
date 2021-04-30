{ lib
, vscode-utils
, fetchFromGitHub
, sumneko-lua-language-server
}:
let
  version = "1.20.4";

  languageServer = sumneko-lua-language-server.overrideAttrs (old: {
    inherit version;

    ninjaFlags = [
      "-fcompile/ninja/linux.ninja"
    ];

    src = fetchFromGitHub {
      owner = "sumneko";
      repo = "lua-language-server";
      rev = "0d11232";
      sha256 = "0wsnbmi0j75fpa6035vpq60ayn152blaf97bry57h1cbcqxnhg65";
      fetchSubmodules = true;
    };

  });
in
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "Lua";
    publisher = "sumneko";
    inherit version;
    sha256 = "186fwsszbha5dfydvw06sfyzi7fz2minahh4l0vyp5a5aaw4v76m";
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
