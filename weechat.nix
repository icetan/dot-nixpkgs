{ lib, stdenv, callPackage, runCommand, makeWrapper, pythonPackages, luaPackages, darwin }:
let
  inherit (builtins) elem attrValues;
  inherit (lib) filterAttrs;
  pluginSupported = (n: elem n [ "lua" "perl" "python" ]);
  weechat-custom = (callPackage (import <nixpkgs/pkgs/applications/networking/irc/weechat>) {
    inherit (darwin) libobjc;
    inherit (darwin) libresolv;
    #lua5 = luajit;
    luaSupport = pluginSupported "lua";
    guileSupport = pluginSupported "guile";
    rubySupport = pluginSupported "ruby";
    tclSupport = pluginSupported "tcl";
    pythonSupport = pluginSupported "python";
    perlSupport = pluginSupported "perl";
    extraBuildInputs = with pythonPackages; [ websocket_client ];

    #configure = null;
    configure = { availablePlugins, ... }: {
      plugins = attrValues (filterAttrs (n: p: pluginSupported n) availablePlugins);
    };

  });
in with luaPackages; runCommand "weechat-wrapper" { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${weechat-custom}/bin/weechat $out/bin/weechat \
    --set ASPELL_CONF 'data-dir $HOME/.nix-profile/lib/aspell' ${
      lib.optionalString stdenv.isLinux ''\
        --set LUA_CPATH "${getLuaCPath cjson}" \
        --set LUA_PATH "${getLuaPath cjson}" ''
    }
''
