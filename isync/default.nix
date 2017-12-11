{ isync, lib, runCommand, makeWrapper, writeText, callPackage }:

accounts: let
  tmpls = {
    "gmail" = callPackage (import ./gmail.nix) {};
    "outlook" = callPackage (import ./outlook.nix) {};
  };
  isync-conf = writeText "mbsyncrc" (
    lib.concatMapStringsSep ''

    '' (a: tmpls."${a.type}" a) accounts
  );
in runCommand "isync-wrapper" { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${isync}/bin/mbsync $out/bin/mbsync \
    --add-flags '-c ${isync-conf}'
  ln -s ${isync}/share $out
''
