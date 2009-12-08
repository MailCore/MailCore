#!/bin/sh
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
