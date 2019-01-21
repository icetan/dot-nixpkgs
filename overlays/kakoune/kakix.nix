{ kakoune, dash, runCommand, writeText, makeWrapper, lib, stdenv }:

{ deps, name ? kakoune.name, binDeps ? [] }: let
  kakrc = writeText "kakrc" (lib.concatMapStrings (fn: ''
    source ${fn}
  '') deps);
  config-kakrc = runCommand "config-kakrc" {} ''
    mkdir -p $out/kak
    ln -s ${kakrc} $out/kak/kakrc
  '';
in runCommand name { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${kakoune}/bin/kak $out/bin/kak \
    --set XDG_CONFIG_HOME ${config-kakrc} \
    --prefix PATH : ${lib.makeBinPath binDeps} \
    --set KAKOUNE_POSIX_SHELL ${dash}/bin/dash
''
