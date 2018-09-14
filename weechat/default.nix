{ lib, stdenv, runCommand, makeWrapper, writeScript
, luaPackages, pythonPackages, fetchgit, fetchurl
, weechat-matrix-bridge, weechat, signal-cli
}: let
  inherit (builtins) readFile;

  deps = (lib.importJSON ./deps.json);
  fetchdep = dep: fetchgit { inherit (dep) url rev sha256 fetchSubmodules; };

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
    ln -s ${./conf}/* $out/

    ln -s ${wee-slack}/wee_slack.py ${go} ${colorize-nicks} ${emoji-aliases} \
      ${beep} ${signal}/signal.py \
      $out/python/autoload/

    ln -s ${weechat-matrix-bridge}/share/matrix.lua \
      $out/lua/autoload/
  '';

  weechat-wrapper = with luaPackages; writeScript "weechat-wrapper" ''
    #!${stdenv.shell}
    export PATH="${signal-cli}/bin:$PATH"
    export ASPELL_CONF="data-dir $HOME/.nix-profile/lib/aspell"
    export LUA_CPATH="${getLuaCPath cjson}"
    export LUA_PATH="${getLuaPath cjson}"
    export WEECHAT_HOME="$HOME/.weechat"
    ln -fs ${conf-dir}/* "$WEECHAT_HOME"
    exec ${weechat'}/bin/weechat "$@"
  '';

  weechat' = weechat.override {
    guileSupport = false;
    rubySupport = false;
    tclSupport = false;
    perlSupport = false;
    extraBuildInputs = [
      luaPackages.cjson
    ];
    configure = {availablePlugins,...}: {
      plugins = with availablePlugins; [
        lua
        (python.withPackages (ps: with ps; [
          websocket_client xmpppy
          dbus-python qrcode  # used by signal plugin
        ]))
      ];
    };
  };
in runCommand "weechat-wrapper" {} ''
  mkdir -p $out/bin
  ln -s ${weechat-wrapper} $out/bin/weechat
''

#with luaPackages; runCommand "weechat-wrapper" { buildInputs = [ makeWrapper ]; } ''
#  makeWrapper ${weechat'}/bin/weechat-2.1 $out/bin/weechat-2.1 \
#    --set ASPELL_CONF 'data-dir $HOME/.nix-profile/lib/aspell' ${
#    lib.optionalString stdenv.isLinux ''\
#        --set LUA_CPATH "${getLuaCPath cjson}" \
#        --set LUA_PATH "${getLuaPath cjson}" \
#        --add-flags "-d ${conf-dir}" ''
#    }
#''
