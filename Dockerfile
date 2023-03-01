FROM linuxserver/swag:latest

# install msmtp package
RUN set-ex; \
	apk add msmtp; \
    ln -sf /usr/bin/msmtp /usr/bin/sendmail; \
    ln -sf /usr/bin/msmtp /usr/sbin/sendmail;

# setup configuration
RUN cat <<EOF >> /etc/msmtprc
# Valeurs par défaut pour tous les comptes
defaults
auth           on
tls            on
tls_starttls   off
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

# pour mon compte OVH MX PLAN
account        ovh
host           ssl0.ovh.net
port           465
from           kcofoni@anolis-management.fr
EOF

RUN --mount=type=secret,id=my_env source /run/secrets/my_env \
    && echo "user           ${USER}" | cat >> /etc/msmtprc \
    && echo "password       ${PASSWORD}" | cat >> /etc/msmtprc

RUN cat <<EOF >> /etc/msmtprc

# Définir le compte par défaut
account default : ovh
EOF

RUN cat <<EOF >> /etc/aliases
root: kcofoni@anolis-management.fr
default: kcofoni@anolis-management.fr
EOF

# mail test script
RUN mkdir -p /root/tests;

RUN cat <<EOT >> /root/tests/welcome_email
printf %b "Subject: Welcome to swag-email
From: kcofoni <kcofoni@anolis-management.fr>
To: kcofoni@gmail.fr\n
Salut,\n
L'image swag-email vient d'etre créée dans docker.\n
Il n'y a plus qu'à exécuter le docker compose qui va donner naissance au containeur correpondant...\n
cordialement" | sendmail "kcofoni@gmail.com"
EOT

RUN cat <<EOF >> /root/tests/testsendmail
sendmail -f kcofoni@anolis-management.fr kcofoni@gmail.com < testsendmail.txt
EOF
RUN cat <<EOF >> /root/tests/testsendmail.txt
Content-Type: text/plain; charset=utf-8
from: swag <kcofoni@anolis-management.fr>
to: kcofoni@gmail.com
subject: ceci est un test d'envoi de mail
Ce message est envoyé de swag-email pour tester l'envoi de mail depuis le container équipé de msmtp
.
EOF
RUN chmod +x /root/tests/testsendmail /root/tests/welcome_email
RUN /root/tests/welcome_email
