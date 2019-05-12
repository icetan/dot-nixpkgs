{ lib, stdenv, runCommand, makeWrapper, writeScriptBin
, luaPackages, pythonPackages, fetchgit, fetchurl, callPackage
, signal-cli , weechat-matrix-bridge
, weechatScripts, wrapWeechat, weechat-unwrapped
, darwin
}: let
  inherit (builtins) readFile;

  deps = (lib.importJSON ./deps.json);
  fetchdep = dep: fetchGit { inherit (dep) url rev; };

  plugins = {
    wee-slack = fetchdep deps.wee-slack;
    #wee-slack = fetchgit {
    #  url = "https://github.com/wee-slack/wee-slack.git";
    #  rev = "v2.0.0";
    #  sha256 = "0712zzscgylprnnpgy2vr35a5mdqhic8kag5v3skhd84awbvk1n5";
    #};

    go = ./plugins/go.py;
    #fetchurl {
    #  url = "https://weechat.org/files/scripts/go.py";
    #  sha256 = "0ajfv4sl66jq02zzmdas81rvnv2l6dl3ckb4xzkyb3kdm68w31rf";
    #};

    colorize-nicks = ./plugins/colorize_nicks.py;
    #fetchurl {
    #  url = "https://weechat.org/files/scripts/colorize_nicks.py";
    #  sha256 = "1ldk6q4yhwgf1b8iizr971vqd9af6cz7f3krd3xw99wd1kjqqbx5";
    #};

    emoji-aliases = ./plugins/emoji_aliases.py;
    #fetchurl {
    #  url = "https://weechat.org/files/scripts/emoji_aliases.py";
    #  sha256 = "0876mqn5sm47fisclsw69grmajah9rwc4gqnf762nshvndlnjyxf";
    #};

    beep = ./plugins/beep.py;
    #fetchurl {
    #  url = "https://weechat.org/files/scripts/unofficial/beep.py";
    #  sha256 = "0wh2cmsajjks5pblrzvqhxkfqvbzv14lxf2gg447lhp7q9gyp9k9";
    #};

    signal = fetchdep deps.signal-weechat;
  };

  conf-dir = with plugins; runCommand "conf-dir" {} ''
    mkdir -p $out/{python,lua}/autoload

    cp -r ${./conf}/* ${wee-slack}/weemoji.json \
      $out/

    # ${wee-slack}/wee_slack.py
    cp -r ${go} ${colorize-nicks} \
      ${beep} ${signal}/signal.py \
      $out/python/autoload/
  '';

  weechat-wrapper = with luaPackages; writeScriptBin "weechat" ''
    #!${stdenv.shell}

    # Signal
    export PATH="${signal-cli}/bin:$PATH"

    # aspell
    export ASPELL_CONF="data-dir $HOME/.nix-profile/lib/aspell"

    # Copy config to ~/.weechat
    export WEECHAT_HOME="$HOME/.weechat"
    mkdir -p "$WEECHAT_HOME"
    cp -rn -t "$WEECHAT_HOME" ${conf-dir}/*
    chmod -R u+w "$WEECHAT_HOME"

    exec ${weechat'}/bin/weechat "$@"
  '';

  weechat' = wrapWeechat weechat-unwrapped {
    configure = { availablePlugins, ... }: {
      scripts = [ weechat-matrix-bridge ];
      plugins = with availablePlugins; [
        lua
        (python.withPackages (ps: with ps; [
          dbus-python qrcode  # used by signal plugin
        ]))
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
