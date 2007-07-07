import os, fnmatch, glob, re

def expandArchive(directory, archiveName):
	""" Given a directory, it will try and find an archive that 
		has name that begins with archiveName and will then expand it """
	for path, subdirs, files in os.walk(directory):
		for filename in files:
			pattern = archiveName+"*.tar.gz"
			if(fnmatch.fnmatch(filename,pattern)):
				archivePath = os.path.join(path, filename)
				os.chdir(directory)
				os.system("tar xzf \""+archivePath+"\"");
				return os.path.join(path, filename[:-7])

def searchAndReplaceInDirectory(directory, regex, replacement):
	""" Given a directory this will go through and do a search and a replace
		with the regex and will replace with replacement """
	for path, subdirs, files in os.walk(directory):
		for name in files:
			fullPath = os.path.join(path,name)
			thefile = open(fullPath,'r+')
			lines = thefile.readlines()
			thefile.close()
			newfile = open(fullPath, 'w')
			newlines = []
			for line in lines:
				newlines.append(re.sub(regex, replacement, line))
			newfile.writelines(newlines)
			newfile.close()