import os, fnmatch, glob, projectutils

# Must be run from the root of the project

if __name__ == "__main__":
	if(os.path.exists("OpenSourceProjects/build") == False):
		os.system('python Scripts/BuildScripts/buildlibetpan.py')

	
	