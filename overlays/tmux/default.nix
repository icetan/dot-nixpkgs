self: super: with super; let
  tmux-conf = writeText "tmux.conf" ''
    source-file ${./tmux.conf}
    source-file ${./theme.conf}
  '';

  tmux-share-src = writeScript "tmux-share" ''
    #!${dash}/bin/dash
    set -e
    die() { echo >&2 $@; exit 1; }
    group=''${1-tmuxshare}
    socket=''${2-/tmp/tmux-shared-$group}
    [ -e $socket ] || tmux -S $socket new-session -d
    [ -S $socket ] || die "$socket is not a socket"
    [ $(stat -c %G $socket) = $group ] || chgrp $group $socket
    [ $(stat -c %G $socket) = $group ] || die "$socket not owned by group $group"
    echo export TMUX=$socket
  '';
in {
  tmux-custom = runCommand "tmux-wrapper" { buildInputs = [ makeWrapper ]; } ''
    makeWrapper ${tmux}/bin/tmux $out/bin/tmux \
      --add-flags '-f ${tmux-conf}'
    ln -s ${tmux}/share $out
  '';

  tmux-share = runCommand "tmux-share" {} ''
    mkdir -p $out/bin
    ln -s ${tmux-share-src} $out/bin/tmux-share
  '';
}
