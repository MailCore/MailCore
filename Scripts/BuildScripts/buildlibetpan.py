import os, fnmatch, glob, projectutils

# Must be run from the root of the MailCore project

if __name__ == "__main__":
	os.system('mkdir OpenSourceProjects/build')
	
	# Build universal libetpan
	print "Expanding libetpan..."
	projectpath = projectutils.expandArchive(os.path.abspath("OpenSourceProjects/"),"libetpan")
	os.chdir(projectpath)
	print "Building libetpan i386"
	os.system('env CPPFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch i386" ./configure --disable-dependency-tracking --host i386')
	os.system('make')
	os.system('mkdir i386')
	os.system('mv src/.libs/*.a i386')
	print "Building libetpan PPC"
	os.system('make clean')
	os.system('env CPPFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -arch ppc" ./configure --disable-dependency-tracking --host ppc')
	os.system('make')
	os.system('mkdir ppc')
	os.system('mv src/.libs/*.a ppc')
	print "Using lipo to create libetpan universal binary"
	os.system('lipo i386/libetpan.a ppc/libetpan.a -output ../build/libetpan.a -create')
	print "Creating headers"
	projectutils.searchAndReplaceInDirectory('include', r'include <libetpan/(.*?)>', r'include "\1"')
	os.system('cp -r include ../')
	
	
	