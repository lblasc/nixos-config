{ stdenv
, vscode-utils
, fetchFromGitHub
, ninja
, clang
}:
let
  version = "1.0.5";

  languageServer = stdenv.mkDerivation {
    name = "lua-language-server";
    inherit version;

    src = fetchFromGitHub {
      owner = "sumneko";
      repo = "lua-language-server";
      rev = "ccb4713";
      sha256 = "0bqwdnd9zklb9h42rba7miknr6w38kl5f232427xak4igyzvydgq";
      fetchSubmodules = true;
    };

    buildInputs = [ ninja clang ];

    buildPhase = ''
      # remove prebuilt binaries
      rm -rf bin
      # First thing I tried was separating luamake into its own
      # expression, believe me it was a bad idea..
      # This project is full of hardcoded paths and tackling whit it
      # will create a big messy pile of patches, so I followed the
      # author's funky way of doing things..
      cd 3rd/luamake/
      ninja -f ninja/linux.ninja
      cd ../../
      ./3rd/luamake/luamake rebuild
    '';

    installPhase = ''
      # not needed
      rm -rf build
      rm -rf ./3rd/luamake

      # just copy the mess
      mkdir $out
      cp -vr . $out/

      # "only" thing left is to tell log module to use /tmp dir
      # instead of store path which is read only
      sed -i "s~ROOT~fs.path('/tmp/lua-language-server')~g" $out/script/workspace.lua
      sed -i "s~log.init(ROOT, ROOT / 'log' / 'service.log')~log.init(fs.path('/tmp/lua/lua-language-server'), fs.path('/tmp/lua-language-server') / 'log' / 'serivce.log')~" $out/main.lua
    '';
  };
in
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "Lua";
    publisher = "sumneko";
    inherit version;
    sha256 = "03m6i2isw43ic6kgal5s44adx69amz6gx7af0a1wvdmj5kxlckh9";
  };

  postInstall = ''
    # don't run chmod in store
    sed -i '/fs.chmodSync/d' $out/$installPrefix/client/out/languageserver.js

    # extension comes with prebuild language server
    rm -rf $out/$installPrefix/server
    ln -s ${languageServer} $out/$installPrefix/server
  '';

  meta = {
    license = stdenv.lib.licenses.mit;
  };
}
