#! /usr/bin/sh

# Run this from the root of the MailCore project
# Pass in as an arg the tag name for the release

mkdir -p build/MailCore
xcodebuild -configuration Release
cp -R build/Release/MailCore.framework build/MailCore
cp -R Documentation/ build/MailCore/Documentation
cd Examples/InboxLister
xcodebuild clean
cd ../MessageSender
xcodebuild clean
cd ../..
cp -R Examples build/MailCore
cp Resources/GETTING_STARTED.txt build/MailCore
cp Resources/LICENSE.txt build/MailCore
cp Resources/RELEASE_NOTES.txt build/MailCore
cd build/MailCore
ln -s Documentation/index.html index.html
hg clone -r $1 https://bitbucket.org/mronge/mailcore/ src
cd ..
tar czf MailCore.tar.gz MailCore
