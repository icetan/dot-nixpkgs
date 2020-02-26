{ kakoune, dash, writeText, runCommand, makeWrapper, lib }:

{ deps, name ? kakoune.name, binDeps ? [] }: let
  #config-kakrc = runCommand "config-kakrc" {} ''
  #  mkdir -p $out/kak
  #  cat > $out/kak/kakrc <<EOF
  #  ${lib.concatMapStrings (fn: ''source ${fn}
  #  '') deps}
  #  EOF
  #'';
  config-kakrc = writeText "kakix.kak"
    (lib.concatMapStrings (fn: ''source ${fn}
    '') deps);

in runCommand name { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${kakoune}/bin/kak $out/bin/kak \
    --run "
      XDG_CONFIG_HOME=\''${XDG_CONFIG_HOME:-~/.config}
      mkdir -p \$XDG_CONFIG_HOME/kak
      ln -sf ${config-kakrc} \$XDG_CONFIG_HOME/kak/kakrc
    " \
    --prefix PATH : ${lib.makeBinPath binDeps} \
    --set KAKOUNE_POSIX_SHELL ${dash}/bin/dash
''
