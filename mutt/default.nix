{ neomutt, msmtp, isync, mu, gnupg, gettext, my-mail-utils
, runCommand, writeText, makeWrapper, lib
}:

# TODO: multi account support for mutt.
account:
  assert account.type == "outlook" || account.type == "generic";
let
  inherit (lib) optionalString;
  muttrc = writeText "muttrc" ''
    # Entries for filetypes
    set mailcap_path = ${./mailcap}

    # Include theme
    source ${./rc/colors-solarized.muttrc}

    # System config
    source ${./rc/muttrc}

    # XXX: Mailbox specific stuff
    set folder = ${account.root}  # mailbox location
    mailboxes +${account.dir}/Inbox \
              +${account.dir}/Archive \
              +${account.dir}/Drafts \
              +${account.dir}/Sent \
              +${account.dir}/Trash \
              +${account.dir}/Junk

    # Other special folders.
    set spoolfile = "+${account.dir}/Inbox"
    set mbox      = "+${account.dir}/Archive"
    set postponed = "+${account.dir}/Drafts"
    set record    = "+${account.dir}/Sent" # Should really be "+${account.dir}/Sent" but to view sent mail in inbox threads
    set trash     = "+${account.dir}/Trash"

    # Saner copy/move dialogs
    macro index C "<copy-message>?<toggle-mailboxes>" "copy a message to a mailbox"
    macro index M "<save-message>?<toggle-mailboxes>" "move a message to a mailbox"
    macro index,pager Y "<save-message>=${account.dir}/Archive<enter>" "move a message to archive mailbox"

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
    --add-flags '-F ${muttrc}' \
    --prefix PATH : ${lib.makeBinPath [
      msmtp isync mu gnupg gettext my-mail-utils
    ]}
  ln -s ${neomutt}/share $out
''
