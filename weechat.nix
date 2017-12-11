{ lib, stdenv, callPackage, runCommand, makeWrapper, pythonPackages, luaPackages, darwin }:
let
  weechat-custom = (callPackage (import <nixpkgs/pkgs/applications/networking/irc/weechat>) {
    inherit (darwin) libobjc;
    inherit (darwin) libresolv;
    #lua5 = luajit;
    luaSupport = true;
    guileSupport = false; guile = null;
    rubySupport = false; ruby = null;
    tclSupport = false; tcl = null;
    extraBuildInputs = with pythonPackages; [ websocket_client ];
  });
in with luaPackages; runCommand "weechat-wrapper" { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${weechat-custom}/bin/weechat $out/bin/weechat \
    --set ASPELL_CONF 'data-dir $HOME/.nix-profile/lib/aspell' ${
      lib.optionalString stdenv.isLinux ''\
        --set LUA_CPATH "${getLuaCPath cjson}" \
        --set LUA_PATH "${getLuaPath cjson}" ''
    }
  ln -s ${weechat-custom}/share $out
''
