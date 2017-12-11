{ pkgs }: let
  pkgs-src = fetchTarball "https://nixos.org/channels/nixos-17.09/nixexprs.tar.xz";
  stablePkgs = import pkgs-src {};

  setPrio = num: drv: pkgs.lib.addMetaAttrs { priority = num; } drv;
  #customEmacsPackages = emacsPackagesNg.override (super: self: {
  #  emacs = emacs25-nox;
  #});

  defaultShellHook = ''
    export PS1="$PS1"
  '';

  #nixPaths = pkgs.lib.listToAttrs (map (x: { name = x.prefix; value = toString x.path; }) builtins.nixPath);
  nixPaths = map (x: x.prefix) builtins.nixPath;
  localConfigExists = builtins.elem "local-config" nixPaths; #?local-config && (builtins.pathExists nixPaths.local-config);
  local = if localConfigExists
     then (import <local-config> { inherit pkgs; })
     else builtins.trace "no <local-config> in NIX path" (x: x);
in local {
  allowUnfree = true;
  allowBroken = true;

  packageOverrides = pkgs: let
    # Uncomment the line below to use a stable nixpkgs
    #pkgs = stablePkgs;
  in
    with pkgs;
  let
    callPackage = lib.callPackageWith (pkgs // self);

    java = (import ./java.nix) { inherit pkgs; };

    self = rec {
      rtrav = runCommand "rtrav" {} ''
        mkdir -p $out/bin
        printf %s 'rtrav_() { test -e $2/$1 && printf %s "$2" || { test $2 != / && rtrav_ $1 `dirname $2`;}; }
        rtrav_ $@' > $out/bin/rtrav
        chmod +x $out/bin/rtrav
      '';

      bashEnv = callPackage (import ./bash.nix) {};

      myNeovim = callPackage (import ./vim) {};

      myKakoune = callPackage (import ./kakoune) {};

      myWeechat = callPackage (import ./weechat.nix) {};

      myTmux = callPackage (import ./tmux) {};

      myGhc = callPackage (import ./haskell.nix) {};

      mailEnv = callPackage (import ./mail) {};

      chatEnv = buildEnv {
        name = "chat-env";
        ignoreCollisions = true;
        paths = [
          myWeechat
        ];
      };

      baseEnv = buildEnv {
        name = "base-env";
        ignoreCollisions = true;
        paths = [
          myTmux
          myKakoune
          git
          qrencode
          pass
          gnupg
          rclone
          tree
        ];
      };

      guiEnv = buildEnv {
        name = "gui-env";
        ignoreCollisions = true;
        paths = [
          rofi
          rofi-pass
          xsel
          #nitrogen
          xautolock
          #termite
          #compton
        ];
      };
    } // java;
  in self;
}
