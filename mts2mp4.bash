#!/bin/bash
shopt -s extglob


function func_help()
{
	echo "  --help or -h: this help"
	echo "  --in=<input file name> or -i=<>"
	#echo "  --insuffix=<filename> where filename must match this input suffix ex: MTS of name.MTS files -s=<>"
	echo "  --donothing or --testrun or -d Dont actuall do anything, just output commands"
	echo "  --dir=<dir>rectory in which to perform action"
	#echo "  --verbose|-v Verbose output"
}

CMD="ffmpeg.exe"
out_suffix="mp4"
in_suffix="MTS"

start_dir=`pwd`

for arg in "$@" ; do
	#echo "DELME0: Argument: ${arg}"

	case $arg in
		--help|-h)
			func_help
			exit
			;;
		--in=*|-i=*)

			if [[ "" != "$basename" ]] ; then
				echo "Warning: Basename was already set to ${basename}. Resetting to new value."
			fi

			basename=`echo ${arg} | awk -F'=' '{print $2}'`
			;;
		#--insuffix=*|-s=*)
#
			#if [[ "" != "$in_suffix" ]] ; then
				#echo "Warning: Suffix was already set to ${in_suffix}. Resetting to new value."
			#fi
#
			#in_suffix=`echo ${arg} | awk -F'=' '{print $2}'`
			#;;
		--dono*|--testrun|-d)
			test_run="true"
			;;
		--dir=*)
			newdir=`echo ${arg} | awk -F'=' '{print $2}'`
			;;
		--verbose|-v)
			verb="true"
			;;
		*)
			echo "Not sure what to do with: $arg .. Ignoring..."
			func_help
			exit
			;;
	esac
done

if [[ "" != ${verb} ]] ; then echo "newdir=${newdir}" ; fi

cd "$newdir"
cwd=`pwd`

if [[ "" != ${verb} ]] ; then echo "inputfile=${basename}" ; fi
if [[ "" != ${verb} ]] ; then echo "CMD=${CMD}" ; fi
if [[ "" != ${verb} ]] ; then echo "test_run=${test_run}" ; fi
if [[ "" != ${verb} ]] ; then echo "start_dir=${start_dir}" ; fi
if [[ "" != ${verb} ]] ; then echo "working dir=${cwd}" ;  fi

#ffmpeg.exe -i "E:\Video\TKD\2011 friendship\2011 friendship_00060.mts" -acodec copy -vcodec copy "E:\Video\TKD\2011 friendship\2011 friendship_00060.mp4

if [[ "" == "${basename}" && "" == "${newdir}" ]] ; then
	echo -e "\e[31mError:\e[0m One of inputfile or directory must be set."
	func_help
	exit 1
elif [[ "" != "${basename}" && "" != "${newdir}" ]] ; then
	echo -e "\e[31mError:\e[0m Only one of inputfile or directory is allowed to be set."
	func_help
	exit 1
elif [[ "" == "${basename}" ]] ; then
	basename="$newdir"
fi

if [[ ! -e ${basename} ]] ; then
	echo "File: ${basename} does not exist"
elif [[ -f ${basename} ]] ; then
	file_bad_basename=`echo ${basename} | awk -F'.' '{$NF="";print $0}'`
	file_basename=`echo ${file_bad_basename} | sed 's/ $//'`
	if [[ "" != "$test_run" ]] ; then 
		echo -e "\e[36mtestrun:\e[0m ${CMD} -i ${basename} -acodec copy -vcodec copy ${file_basename}.${out_suffix}"
	else
		echo ${CMD} -i "${basename} -acodec copy -vcodec copy ${file_basename}.${out_suffix}"
		${CMD} -i "${basename}" -acodec copy -vcodec copy "${file_basename}.${out_suffix}"
	fi
elif [[ -d ${newdir} ]] ; then
	for file in * ; do
		echo DELME: file: ${file}
		file_suf=`echo ${file} | awk -F'.' '{print $NF}'`
		file_bad_basename=`echo ${file} | awk -F'.' '{$NF="";print $0}'`
			#HACK ALERT: every file has a space placed at the end making the tests fail
		file_basename=`echo ${file_bad_basename} | sed 's/ $//'`


		if [[ ! -f $file ]] ; then
			if [[ "" != ${verb} ]] ; then echo -e "\e[33mskipping\e[0m \"${file}\" (not a file after all)" ; fi
		elif [[ "${file_suf}" == "${in_suffix}" ]] ; then
			newname=${basename}_${file}

			if [[ "" != "$test_run" ]] ; then 
				echo -e "\e[36mtestrun:\e[0m ${CMD} -i ${file} -acodec copy -vcodec copy ${file_basename}.${out_suffix}"
			else
				echo ${CMD} -i "${file} -acodec copy -vcodec copy ${file_basename}.${out_suffix}"
				${CMD} -i "${file}" -acodec copy -vcodec copy "${file_basename}.${out_suffix}"
			fi
		else
			echo -e "\e[33mskipping\e[0m \"${file}\" (no input suffix match)"
		fi
	done
else
	echo "I'm confused about File: ${file}."
fi

