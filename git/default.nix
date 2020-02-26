{ lib, stdenv, callPackage, writeText, runCommand, makeWrapper, bash, git, gnupg }:

{ extraConf ? null, excludesFile ? null }:

let
  inherit (builtins) toString readFile;
  inherit (lib.strings) optionalString;
  inherit (lib) makeBinPath;

  git-commit-msg = writeText "commit-msg" ''
    #!/bin/bash
    set -e

    grepit() { grep -Eo '^[A-Z]{1,}-[0-9]{1,}\b' "$@"; }
    grepid() { grepit -q "$1"; }

    grepid "$1" || {
      branch_name=$(git rev-parse --abbrev-ref HEAD 2>&-)
      grepid <(echo $branch_name) && {
        jid=$(grepit <(echo "$branch_name "))
        sed -i"" "1s/^/$jid /" "$1"
      }
    } || exit 0
  '';
  templatedir = runCommand "git-template" {} ''
    mkdir -p $out/hooks
    cp ${git-commit-msg} $out/hooks/commit-msg
    chmod +x $out/hooks/commit-msg
  '';

  gitconfig = writeText "gitconfig" (
    (optionalString (extraConf != null) ''
      [include]
          path = ${toString extraConf}
    '')

    + (optionalString (excludesFile != null) ''
      [core]
          excludesFile = ${toString excludesFile}
    '')

    + (''
      [init]
          templateDir = ${templatedir}
    '')

    + (readFile ./gitconfig)
  );
in runCommand "git-wrapper" { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${git}/bin/git $out/bin/git \
    --run "
      XDG_CONFIG_HOME=\''${XDG_CONFIG_HOME:-~/.config}
      mkdir -p \$XDG_CONFIG_HOME/git
      ln -sf ${gitconfig} \$XDG_CONFIG_HOME/git/config
    " \
    --set GIT_CONFIG_NOSYSTEM 1 \
    --prefix PATH : ${makeBinPath [ gnupg ]}
''
