#!/c/python27/python

import sys
import getopt
import os
import subprocess
import hashlib


def func_help():
	print '  --help or -h: this help'
	print '  --verbose|-v Verbose output'
	print '  --quick | -q Uses only the first lines for the md5sum'

def walkdir(mypath):
	#print 'DELME: mypath:' , mypath
	file_paths = []
	for (root, dirs, files) in os.walk(mypath):
		for filename in files:
			#print 'DELME: filename:' , filename
			# Join the two strings in order to form the full filepath.
			filepath = os.path.join(root, filename)
			#print 'DELME: filepath:' , filepath
			file_paths.append(filepath)  # Add it to the list.
		for dirname in dirs:
			#print 'DELME: dirname:' , dirname
			dirpath = os.path.join(root, dirname)
			file_paths.extend(walkdir(dirpath))
		break
	return file_paths

def md5(fname):
	data_size=65536
	hash = hashlib.md5()
	with open(fname) as f:
		size = os.fstat(f.fileno()).st_size
		if size > 2*data_size:
			f.seek(size/2);
			#print 'DELME:size of %s is %d' % (fname,size)
			#file_head = f.read(data_size)
			#hash.update(file_head)
			size=data_size
		file_head = f.read(size)
		hash.update(file_head)
			
	return hash.hexdigest()

def getKey(item):
	return item[0]

def list_duplicates(input_seq):
	seq=input_seq
	all_dups=[]
	length = len(seq)
	#print 'DELME: len:%d', length
	i = 0
	while i < length:
		j = i+1
		item_dup=[seq[i][1]]
		#print 'DELME: i:%d' % i
		while j < length:
			item1 = seq[i]
			item2 = seq[j]
			#print 'DELME: j:%d' % j
			if item1[0] == item2[0]:
				#print 'DELME:%s = %s from %s , %s' % (item1[0], item2[0], item1[1], item2[1])
				s=item2[1]
				item_dup.extend([s])
				seq.remove(item2)
			else:
				j+=1
			length = len(seq)
		if len(item_dup) > 1:
			print 'DELME: ADDING:', item_dup
			all_dups.append(item_dup)
			seq.remove(item1)
		else:
			i+=1
		length = len(seq)
	print 'DELME:all_dups:'
	#for itr in all_dups: #DELME
		#print itr #DELME
	#print all_dups #DELME
	return all_dups


def main (argv):
	quick_run = "false"
	verb = "false"
	print 'Hello world'
	sorted_by_md5 = []
	try:
		opts, args = getopt.getopt(argv,"hvq",["help","verbose","quick"])
	except getopt.GetoptError:
		func_help()
		sys.exit(2)
	for opt, arg in opts:
		if opt in ("-h" , "--help"):
			func_help()
			sys.exit()
		elif opt in ("-v" , "--verbose"):
			verb = "true"
		elif opt in ("-q" , "--quick"):
			quick_run = "true"
		else:
			print 'Not sure what to do with: ' , opt
			func_help()
			sys.exit(2)
	cwd = os.getcwd()
	all_files = walkdir(cwd)
	#print 'DELME:All files found:' , all_files

	for filename in all_files:
		sorted_by_md5.extend([(md5(filename),filename)])

	#print 'DELME:sorted_by_md5 files found:' , sorted_by_md5
	#sorted_by_md5.sort(key=lambda tup: tup[0])
	sorted_by_md5.sort()
	for filename in sorted_by_md5:
		print '%s,%s' % filename

	dups = list_duplicates(sorted_by_md5)
	for dup in dups: #DELME
		for item in dup:
			sys.stdout.write(item)
			sys.stdout.write(",")
		sys.stdout.write("\n")
	#print 'DELME dups:\n' , filename
	

if __name__ == "__main__":
   main(sys.argv[1:])
