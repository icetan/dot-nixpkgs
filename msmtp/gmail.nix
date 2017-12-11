{ cacert, pass }: account@{ name, email, pass-path, ... }: ''
account ${name}
host smtp.gmail.com
port 587
protocol smtp
auth on
from ${email}
user ${email}
passwordeval ${pass}/bin/pass show ${pass-path} | head -n1
tls on
tls_starttls on
tls_trust_file ${cacert}/etc/ssl/certs/ca-bundle.crt
''
