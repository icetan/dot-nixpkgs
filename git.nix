{ lib, stdenv, callPackage, writeText, runCommand, makeWrapper, git, bash }:

{ extraConf ? "" }:

let
  gitinclude = writeText "gitconfig-local" extraConf;
  gitignore = writeText "gitignore" ''
    *~
    .DS_Store
    node_modules/

    GPATH
    GRTAGS
    GTAGS
    tags

    *.min.js
    *.min.css
    *.js.map

    .classpath
    .project
    .settings/
    workbench.xmi

    .ensime
    .ensime_cache/

    result*

    .lvimrc
  '';

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

  gitconfig = writeText "gitconfig" ''
    [include]
        path = ${gitinclude}
    [core]
        excludesfile = ${gitignore}
    [push]
        default = simple
    [alias]
        fap = fetch --all --prune
        s    = status -s
        glog = log --graph --decorate
        ls   = log --pretty=format:"%C(auto)%h\\ (%ad)\\ %Cblue<%an>%x09%Creset%s%C(auto)%d" --decorate --date=relative
        lss  = log --pretty=format:"%C(auto)%h\\ (%ad)\\ %Cblue<%an>\\ %G?%x09%Creset%s%C(auto)%d" --decorate --date=relative
        lsg  = log --pretty=format:"%C(auto)%h\\ (%ad)\\ %Cblue<%an>%x09%Creset%s%C(auto)%d" --decorate --date=relative --graph
        lsga = log --pretty=format:"%C(auto)%h\\ (%ad)\\ %Cblue<%an>%x09%Creset%s%C(auto)%d" --decorate --date=relative --graph --all
        incoming = "!git remote update -p; git log ..@{u}"
        outgoing = log @{u}..
        # worktree
        wl = worktree list
        wa = worktree add
        wp = worktree prune
    [init]
        templatedir = ${templatedir}
    [rebase]
        autosquash = true
    [rerere]
        enable = true
  '';

  templatedir = runCommand "git-template" {} ''
    mkdir -p $out/hooks
    ln -s ${git-commit-msg} $out/hooks/commit-msg
  '';
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
