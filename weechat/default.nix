{ lib, stdenv, runCommand, makeWrapper, writeScriptBin
, luaPackages, pythonPackages, fetchgit, fetchurl, callPackage
, signal-cli , weechat-matrix-bridge
, weechatScripts, wrapWeechat, weechat-unwrapped
, darwin
}: let
  inherit (builtins) readFile;

  deps = lib.importJSON ./deps.json;
  fetchdep = dep: fetchGit { inherit (dep) url rev; };

  plugins = {
    wee-slack = fetchdep deps.wee-slack;

    go = ./plugins/go.py;

    colorize-nicks = ./plugins/colorize_nicks.py;

    emoji-aliases = ./plugins/emoji_aliases.py;

    beep = ./plugins/beep.py;

    #signal = fetchdep deps.signal-weechat;
  };

  conf-dir = with plugins; runCommand "conf-dir" {} ''
    mkdir -p $out/{python,lua}/autoload

    cp -r ${./conf}/* ${wee-slack}/weemoji.json \
      $out/

    cp -r ${go} ${colorize-nicks} ${beep} \
      $out/python/autoload/
  '';
  # ${signal}/signal.py
  # ${wee-slack}/wee_slack.py

  # Signal
  #export PATH="${signal-cli}/bin:$PATH"
  weechat-wrapper = with luaPackages; writeScriptBin "weechat" ''
    #!${stdenv.shell}

    # aspell
    export ASPELL_CONF="data-dir $HOME/.nix-profile/lib/aspell"

    # matrix
    export LUA_CPATH="${getLuaCPath cjson}"
    export LUA_PATH="${getLuaPath cjson}"

    # Copy config to ~/.weechat
    export WEECHAT_HOME="$HOME/.weechat"
    mkdir -p "$WEECHAT_HOME"
    cp -rn -t "$WEECHAT_HOME" ${conf-dir}/*
    chmod -R u+w "$WEECHAT_HOME"

    exec ${weechat'}/bin/weechat "$@"
  '';

  weechat' = wrapWeechat weechat-unwrapped {
    configure = { availablePlugins, ... }: {
      scripts = [
        weechat-matrix-bridge
      ];
      plugins = with availablePlugins; [
        lua
        #(python.withPackages (ps: with ps; [
        #  dbus-python qrcode  # used by signal plugin
        #]))
      ];
    };
  };
in weechat-wrapper

#with luaPackages; runCommand "weechat-wrapper" { buildInputs = [ makeWrapper ]; } ''
#  makeWrapper ${weechat'}/bin/weechat-2.1 $out/bin/weechat-2.1 \
#    --set ASPELL_CONF 'data-dir $HOME/.nix-profile/lib/aspell' ${
#    lib.optionalString stdenv.isLinux ''\
#        --set LUA_CPATH "${getLuaCPath cjson}" \
#        --set LUA_PATH "${getLuaPath cjson}" \
#        --add-flags "-d ${conf-dir}" ''
#    }
#''
