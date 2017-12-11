{ neomutt, runCommand, writeText, makeWrapper, lib }:

# TODO: multi account support for mutt.
account:
  assert account.type == "outlook";
let
  inherit (lib) optionalString;
  muttrc = writeText "muttrc" ''
    # Entries for filetypes
    set mailcap_path = ${./mailcap}

    # Include theme
    source ${./rc/colors-solarized.muttrc}

    # System config
    source ${./rc/muttrc}

    # Local config
    set realname = '${account.fullname}'
    set from = '${account.email}'

    # Include GPG for signing and ecrypting email if sing-key pressent
    ${optionalString (account ? sign-key) ''
      source ${./rc/gpg.muttrc}
      set pgp_sign_as = ${account.sign-key}
    ''}
  '';
in runCommand "mutt-wrapper" { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${neomutt}/bin/neomutt $out/bin/neomutt \
    --add-flags '-F ${muttrc}'
  ln -s ${neomutt}/share $out
''
