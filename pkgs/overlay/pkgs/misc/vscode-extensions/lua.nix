{ stdenv
, vscode-utils
, fetchFromGitHub
, ninja
, clang
}:

let
  version = "0.17.1";

  languageServer = stdenv.mkDerivation {
    name = "lua-language-server";
    inherit version;

    src = fetchFromGitHub {
      owner = "sumneko";
      repo = "lua-language-server";
      rev = "da43d80";
      sha256 = "07jw8v0j7yyifivfqlfpb5rw96027i6rhv21dxhdbl54hbk4d7p0";
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
in vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "Lua";
    publisher = "sumneko";
    inherit version;
    sha256 = "0k04cp0r93907ix5hz827r95g7sky44w8md3b9il9gn4z6jvmq67";
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
