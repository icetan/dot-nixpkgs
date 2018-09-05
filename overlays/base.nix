self: super: with super; let
  setPrio = num: drv: self.lib.addMetaAttrs { priority = num; } drv;
in rec {
  my-kakoune = callPackage (import ../kakoune) {};
  my-weechat = callPackage (import ../weechat) {};
  bash-env = callPackage (import ../bash.nix) {};
  my-git = (callPackage (import ../git) {}) {
    extraConf = ~/.local/gitconfig;
    excludesFile = git/gitignore;
  };
  my-tmux = callPackage (import ../tmux) {};
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
      my-tmux
      my-kakoune
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

      #termite
      #compton
      #nitrogen
    ];
  };
}
