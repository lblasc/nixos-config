{ pkgs
, ... }:

let
  version = "0.16.3";

  languageServer = pkgs.clangStdenv.mkDerivation {
    name = "lua-language-server";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "sumneko";
      repo = "lua-language-server";
      rev = "ff4fda5";
      sha256 = "0vz9w0m70mvgyrs18114s0g9hrq4xzmjk0vhmprg7l5xrjnvj0wf";
      fetchSubmodules = true;
    };

    buildInputs = [ pkgs.ninja ];

    buildPhase = ''
      # remove prebuilt binaries
      rm -rf bin
      # First thing I tried was separating luamake into in its own
      # expression, belive me it was bad idea..
      # This project is full of hardcoded paths and tackling whith it
      # will create big messy pile of patches, so I followed the
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
in pkgs.vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "Lua";
    publisher = "sumneko";
    inherit version;
    sha256 = "03hrp248j8wiip1ww19bypclqzh58qv7if15lrf3r3yfavl007l0";
  };

  postInstall = ''
    # don't run chmod in store
    sed -i '/fs.chmodSync/d' $out/$installPrefix/client/out/languageserver.js

    # extension comes with prebuild language server,
    # let's remove it and use our build 
    rm -rf $out/$installPrefix/server
    ln -s ${languageServer} $out/$installPrefix/server
  '';

  meta = {
    license = pkgs.stdenv.lib.licenses.mit;
  };
}
