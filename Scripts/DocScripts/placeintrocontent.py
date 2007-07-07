import sys
import os


def main():
	file = open("documentation/html/index.html","r")
	text = ""
	lines = file.readlines()
	for s in lines:
		text=text+s
	
	startIndex=text.find("<ul>")
	endIndex=text.find("</ul>")
	introFile = open("resources/introduction.html")
	introLines = introFile.readlines()
	introText = ""
	for s in introLines:
		introText=introText+s
	newString = text[0:startIndex]+introText+text[endIndex+5:]
	file = open("documentation/html/index.html","w")
	file.writelines(newString)


if __name__ == '__main__':
    main()

