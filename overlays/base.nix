self: super: with super; let
  setPrio = num: drv: self.lib.addMetaAttrs { priority = num; } drv;
in rec {
  my-weechat = callPackage (import ../weechat) {};
  my-git = (callPackage (import ../git) {}) {
    extraConf = ~/.local/gitconfig;
    excludesFile = ../git/gitignore;
  };
  mail-env = callPackage (import ../mail) {};
  chat-env = self.buildEnv {
    name = "chat-env";
    ignoreCollisions = true;
    paths = [
      my-weechat
    ];
  };

  base-env = setPrio 1 (self.buildEnv {
    name = "base-env";
    ignoreCollisions = true;
    paths = [
      self.kakoune-plugins
      self.tmux-custom
      self.tmux-share
      my-git

      gitAndTools.hub
      git-crypt
      tree
      ripgrep
      jq
      qrencode
      paperkey
      rclone

      pass
      gnupg

      aspell
      aspellDicts.en
      aspellDicts.sv
    ];
  });

  gui-env = self.buildEnv {
    name = "gui-env";
    ignoreCollisions = true;
    paths = [
      rofi
      rofi-pass
      xsel
      maim
      xautolock
      i3status-rust
      feh

      #termite
      #compton
      #nitrogen
    ];
  };
}
