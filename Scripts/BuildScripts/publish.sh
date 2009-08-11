#! /usr/bin/sh

# Run this from the root of the MailCore project
# Arg 1 is the tag name

cp -r Documentation API
scp -r API mronge.com:/var/www/mronge/m/MailCore/API
scp build/MailCore.tar.gz mronge.com:/var/www/mronge/m/MailCore/MailCore-$1.tar.gz
