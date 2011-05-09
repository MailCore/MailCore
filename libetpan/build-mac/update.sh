#!/bin/sh
OPENSSL_VERSION=0.9.8l

if test ! -d libetpan.xcodeproj ; then
	exit 1;
fi

cd ..
./autogen.sh
make stamp-prepare-target
make libetpan-config.h
cd build-mac
mkdir -p include/libetpan
cp -r ../include/libetpan/ include/libetpan/
cp ../config.h include
cp ../libetpan-config.h include
rm -rf OpenSSL
mkdir -p OpenSSL
cd OpenSSL
curl -O http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
tar xzvf openssl-$OPENSSL_VERSION.tar.gz
mv openssl-$OPENSSL_VERSION/* .
rm -rf openssl-$OPENSSL_VERSION
