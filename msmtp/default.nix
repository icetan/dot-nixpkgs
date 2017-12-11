{ msmtp, lib, runCommand, makeWrapper, writeText, callPackage }:

accounts: let
  tmpls = {
    "gmail" = callPackage (import ./gmail.nix) {};
    "outlook" = callPackage (import ./outlook.nix) {};
  };
  msmtprc = writeText "msmtprc" (lib.concatMapStringsSep ''

  '' (a: tmpls."${a.type}" a) accounts);
in runCommand "msmtp-wrapper" { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${msmtp}/bin/msmtp $out/bin/msmtp \
    --add-flags '-C ${msmtprc}'
  ln -s ${msmtp}/share $out
''
