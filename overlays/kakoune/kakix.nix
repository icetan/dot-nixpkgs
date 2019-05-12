{ kakoune, dash, runCommand, makeWrapper, lib }:

{ deps, name ? kakoune.name, binDeps ? [] }: let
  config-kakrc = runCommand "config-kakrc" {} ''
    mkdir -p $out/kak
    cat > $out/kak/kakrc <<EOF
    ${lib.concatMapStrings (fn: ''source ${fn}
    '') deps}
    EOF
  '';
in runCommand name { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${kakoune}/bin/kak $out/bin/kak \
    --set XDG_CONFIG_HOME ${config-kakrc} \
    --prefix PATH : ${lib.makeBinPath binDeps} \
    --set KAKOUNE_POSIX_SHELL ${dash}/bin/dash
''
