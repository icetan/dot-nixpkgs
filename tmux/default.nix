{ tmux, runCommand, makeWrapper, writeText }:
let
  tmux-conf = writeText "tmux.conf" ''
    source-file ${./tmux.conf}
    source-file ${./theme.conf}
  '';
in runCommand "tmux-wrapper" { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${tmux}/bin/tmux $out/bin/tmux \
    --add-flags '-f ${tmux-conf}'
  ln -s ${tmux}/share $out
''
