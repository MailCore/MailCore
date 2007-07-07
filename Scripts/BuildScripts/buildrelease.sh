#! /usr/bin/sh

# Run this from the root of the MailCore project

mkdir ../../build/MailCore
cp -R ../../build/Release/MailCore.framework ../../build/MailCore
cp -R Documentation/ ../../build/MailCore/Documentation
cd Examples/InboxLister
xcodebuild clean
cd ../MessageSender
xcodebuild clean
cd ../..
xcodebuild -configuration Release
cp -R Examples ../../build/MailCore
cp Resources/README.txt ../../build/MailCore
cp Resources/LICENSE.txt ../../build/MailCore
cp Resources/RELEASE_NOTES.txt ../../build/MailCore
cd ../../build/MailCore
ln -s Documentation/index.html index.html
cd ../..
#hdiutil create -srcfolder build/MailCore build/MailCore.dmg
cd build
tar czf MailCore.tar.gz MailCore
