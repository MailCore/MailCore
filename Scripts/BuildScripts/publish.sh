#! /usr/bin/sh

# Run this from the root of the MailCore project

scp -r Documentation theronge.com:/var/www/theronge.com/docs/MailCore/
cd ../../build/
name="MailCore-$1.tar.gz"
echo $name
mv MailCore.tar.gz $name
scp $name theronge.com:/var/www/theronge.com/docs/MailCore
