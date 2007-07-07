#!/bin/sh

destination=Documentation
doxygen=/Applications/Doxygen.app/Contents/Resources/doxygen
resources=Resources
config=$resources/doxygen.conf
output=Documentation
scripts=Scripts/DocScripts

if [ -e "$doxygen" ]; then
	# run doxygen, it will know where to place the files
	# save stderr output to a file
	$doxygen $config &> /dev/null

	python $scripts/PlaceIntroContent.py

	# purge & create destination directory
	rm -rf $destination/API
	mkdir -p $destination/API

	# transform the source files
	for file in `ls $output/html | grep .html`;
	do
		xsltproc --html $resources/transform.xsl $output/html/$file > $destination/API/$file;
	done

	xsltproc $resources/transform.xsl $resources/menu.xml > $destination/API/classes.html

	# copy all images and stylesheets
	cp $output/html/*.png $output/html/*.css $destination/API
	cp $resources/*.css $destination/API

	mv $output/API .
	rm -rf $output
	mv API Documentation
else
	echo "#WARNING: /Applications/Doxygen.app could not be found. Documentation will not be generated."
fi
