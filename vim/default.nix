{ pkgs } : with pkgs; let

  # Use vimUtils.makeCustomizable if you want to be able to load plugins from
  # ~/.config/nvim, this is a copied and modified version of that expression
  # (find it in <nixpkgs>/pkgs/misc/vim-plugins/vim-utils.nix).
  #makeCustomizable = vim: vim // {
  #  customize = {name, vimrcConfig}: let
  #    lol = (builtins.trace (toString vim) "");
  #    # Clear vim's runtime paths before reading rest of config.
  #    vimrcFile = writeText "vimrc" (
  #      lol + "echo &rtp\nset rtp=\"\"\n" + (builtins.readFile (vimUtils.vimrcFile vimrcConfig))
  #    );
  #  in vimUtils.vimWithRC {
  #    vimExecutable = "${vim}/bin/vim";
  #    inherit name vimrcFile;
  #  };
  #};
  inherit (vimUtils) makeCustomizable;

  neovim-customizable = makeCustomizable (callPackage (import <nixpkgs/pkgs/applications/editors/neovim>) {
    withPython = true;
    extraPythonPackages = with python27Packages; [
      neovim
      sexpdata
      websocket_client
    ];
    withPython3 = false;
    vimAlias = true;
  });
in
  (neovim-customizable.customize {
    vimrcConfig.vam.pluginDictionaries = [
      # load always
      { names = [
        # Movement and navigation
        "easymotion"
        "unimpaired"
        "tmux-navigator"
        "goyo"
        # TODO: Missing from nixpkgs need to nix wrap
        #"vim-skip"
        #"vim-indentwise"

        # Formating
        "surround"
        "tabular"

        # Project management
        #"neomake"
        "ctrlp"
        "ctrlp-cmatcher"
        "vim-localvimrc"
        "vim-auto-save"
        "vinegar"

        "yankround"

        # UI
        "lightline-vim"

        # VCS
        "vim-signify"
        "fugitive"

        # Themes
        "solo-theme"

        # Language support
        #"vim-scala"
        #"vim-nix"
        "vim-hdevtools"
        "typescript-vim"
        #"confluencewiki"

        # To be able to load ensime.py python plugin you must generate the
        # remote plugin manifest (~/.local/share/nvim/rplugin.vim) using
        # :UpdateRemotePlugins. Meaning VAM must load ensime at start.
        # Not until the manifest is created will the ensime commands become
        # available through the runtime path (~/.local/share/nvim) added by
        # default. Thus always loading it on start independent of VAM.
        "ensime"
      ];}

      # Conditional loading of file type specific plugins doesn't work D:
      { name = "vim-scala";       ft_regex = "^scala\$";           }
      { name = "vim-nix";         ft_regex = "^nix\$";             }
      { name = "confluencewiki";  ft_regex = "^confluencewiki\$";  }

      # provide plugin which can be loaded manually:
      #{ name = "phpCompletion"; tag = "lazy"; }

      # full documentation at github.com/MarcWeber/vim-addon-manager
    ];

    # Available plugins
    vimrcConfig.vam.knownPlugins = vimPlugins // {
      # Custom plugins
      solo-theme = vimUtils.buildVimPluginFrom2Nix {
        name = "vim-colors-solo-2016-05-18";
        src = fetchgit {
          url = "git://github.com/icetan/vim-colors-solo";
          rev = "05295fc375dcc098735ec35aa654b704a68a9495";
          sha256 = "04c5sc692754066q7xlvjkirs0r9nmvlg12dsqxka0zadg721an1";
        };
      };

      yankround = vimUtils.buildVimPluginFrom2Nix {
        name = "vim-yankround-2015-12-12";
        src = fetchgit {
          url = "git://github.com/LeafCage/yankround.vim";
          rev = "bced716bb283a328c4dbec056bba36e53b2b404b";
          sha256 = "11wks423dl51xw8dydf12jiv6q295j3vxynw0nvn7w3fqw34f24q";
        };
      };

      unimpaired = vimUtils.buildVimPluginFrom2Nix {
        name = "vim-unimpaired-2015-12-28";
        src = fetchgit {
          url = "git://github.com/tpope/vim-unimpaired";
          rev = "11dc568dbfd7a56866a4354c737515769f08e9fe";
          sha256 = "1an941j5ckas8l3vkfhchdzjwcray16229rhv3a1d4pbxifwshi8";
        };
      };

      ensime = vimUtils.buildVimPluginFrom2Nix {
        name = "vim-ensime-2015-12-28";
        src = fetchgit {
          url = "git://github.com/ensime/ensime-vim";
          rev = "396d5bdf00e0e9c6318a461b571a4f134fdc93fb";
          sha256 = "1cvmm1k4vxyw4dg5jgksvp2wmwxpzg6hg96yc50w86542gjnyc88";
        };
      };

      vim-scala = vimUtils.buildVimPluginFrom2Nix {
        name = "vim-scala-2016-08-03";
        src = fetchgit {
          url = "git://github.com/derekwyatt/vim-scala";
          rev = "a6a350f7c632d0e640b57f9dcc7e123409a7bcd7";
          sha256 = "108c5h02vcb3pnr3si8dhwq3mv2pj5d83mj1ljxdk9595xv8j2rp";
        };
      };

      confluencewiki = vimUtils.buildVimPluginFrom2Nix {
        name = "confluencewiki-2016-04-08";
        src = fetchgit {
          url = "git://github.com/chadburrus/confluencewiki.vim";
          rev = "8ba795661d41e643718b172a0f1b016f0d896ff9";
          sha256 = "0qzyy1pvvmci310nywq69k46k6n0sr6dkry3640grbklq83xi2hz";
        };
      };
    };

    # vimrc
    vimrcConfig.customRC = builtins.readFile ./init.vim;

    name = "nvim";
  }) // { name = "neovim-custom"; }
