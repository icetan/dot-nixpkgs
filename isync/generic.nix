{ cacert, pass }: { imapHost, name, root, dir, email, pass-path, ... }: ''
IMAPAccount ${name}
# Address to connect to
Host ${imapHost}
User ${email}
PassCmd "${pass}/bin/pass show ${pass-path} | head -n1"
# Use SSL
SSLType IMAPS
CertificateFile ${cacert}/etc/ssl/certs/ca-bundle.crt

IMAPStore ${name}-remote
Account ${name}

MaildirStore ${name}-local
# The trailing "/" is important
Path ${root}/${dir}/
Inbox ${root}/${dir}/Inbox

Channel ${name}
Master :${name}-remote:
Slave :${name}-local:
# Mailboxes to sync
Patterns "INBOX" "Archive" "Drafts" "Sent" "Trash" "Junk"
# Automatically create missing mailboxes, both locally and on the server
Create Both
Expunge Both
# Save the synchronization state files in the relevant directory
SyncState *
''
