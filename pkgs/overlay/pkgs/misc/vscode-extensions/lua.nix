{ lib
, vscode-utils
, fetchFromGitHub
, sumneko-lua-language-server
}:
let
  version = "1.14.2";

  languageServer = sumneko-lua-language-server.overrideAttrs (old: {
    inherit version;

    src = fetchFromGitHub {
      owner = "sumneko";
      repo = "lua-language-server";
      rev = version;
      sha256 = "0rqqbr2vqjcbsz8psvskz2lwv2klnfbv7izxa8ygg5ws9wnymm78";
      fetchSubmodules = true;
    };

  });
in
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "Lua";
    publisher = "sumneko";
    inherit version;
    sha256 = "1n15gdrgcbgm4jd2895gxkx4m7khh1bplh76q1lq9f6n5qh5fdc8";
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
