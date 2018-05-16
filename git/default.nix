{ lib, stdenv, callPackage, writeText, runCommand, makeWrapper, git, bash }:

{ extraConf ? null, excludesFile ? null }:

let
  inherit (builtins) toString readFile;
  inherit (lib.strings) optionalString;

  git-commit-msg = writeText "commit-msg" ''
    #!${bash}/bin/bash
    set -e

    grepit() { grep -Eo '^[A-Z]{1,}-[0-9]{1,}\b' $@; }
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
    ln -s ${git-commit-msg} $out/hooks/commit-msg
  '';

  gitconfig = writeText "gitconfig" (
    (optionalString (extraConf != null) ''
      [include]
          path = ${toString extraConf}
    '')

    + (optionalString (excludesFile != null) ''
      [core]
          excludesfile = ${toString excludesFile}
    '')

    + (readFile ./gitconfig)
  );

  homedir = runCommand "gitconfig-home" {} ''
    mkdir -p $out
    ln -s ${gitconfig} $out/.gitconfig
  '';
in runCommand "git-wrapper" { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${git}/bin/git $out/bin/git \
    --set GIT_CONFIG_NOSYSTEM 1 \
    --set XDG_CONFIG_HOME '${homedir}' \
    --set HOME '${homedir}'
''
