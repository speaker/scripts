#!/bin/bash
shopt -s extglob


function func_help()
{
	echo "  --help or -h: this help"
	echo "  --basename=<name to pre-pend when making new file> or -b=<>"
	echo "  --suffix=<filename> where filename must match this suffix ex: MTS of name.MTS files -s=<>"
	echo "  --donothing or --testtun or -d Dont actuall do anything, just output commands"
	echo "  --move -mv -m Move do not copy files"
	echo "  --dir=<dir>rectory in which to perform action"
	echo "  --verbose|-v Verbose output"
}

CMD="cp"

start_dir=`pwd`

for arg in "$@" ; do
	#echo "DELME0: Argument: ${arg}"

	case $arg in
		--help|-h)
			func_help
			exit
			;;
		--basename=*|-b=*)

			if [[ "" != "$basename" ]] ; then
				echo "Warning: Basename was already set to ${basename}. Resetting to new value."
			fi

			basename=`echo ${arg} | awk -F'=' '{print $2}'`
			;;
		--suffix=*|-s=*)

			if [[ "" != "$suffix" ]] ; then
				echo "Warning: Suffix was already set to ${suffix}. Resetting to new value."
			fi

			suffix=`echo ${arg} | awk -F'=' '{print $2}'`
			;;
		--dono*|--testrun|-d)
			test_run="true"
			;;
		--move*|--mv|-m)
			CMD="mv"
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

if [[ "" == "${basename}" ]] ; then
	basename=`basename "${cwd}"`
fi

if [[ "" != ${verb} ]] ; then echo "basename=${basename}" ; fi
if [[ "" != ${verb} ]] ; then echo "suffix=${suffix}" ; fi
if [[ "" != ${verb} ]] ; then echo "CMD=${CMD}" ; fi
if [[ "" != ${verb} ]] ; then echo "test_run=${test_run}" ; fi
if [[ "" != ${verb} ]] ; then echo "start_dir=${start_dir}" ; fi
if [[ "" != ${verb} ]] ; then echo "working dir=${cwd}" ;  fi

file_list=*

#for file in "${file_list}" ; do
for file in * ; do
	file_suf=`echo ${file} | awk -F'.' '{print $NF}'`

	file_bad_basename=`echo ${file} | awk -F'.' '{$NF="";print $0}'`
	file_basename=`echo ${file_bad_basename} | sed 's/ $//'`

	base_match=""

	#HACK ALERT: every file has a space placed at the end making the tests fail

	if [[ ! -f $file ]] ; then
		if [[ "" != ${verb} ]] ; then echo -e "\e[33mskipping\e[0m \"${file}\" (not a file after all)" ; fi
	elif [[ `echo -n ${file_basename} | sed 's/ $//' | grep -E '^[0-9]+$'` ]] ; then
		base_match="true"
	elif [[ `echo -n ${file_basename} | grep -E '^CIMG[0-9]+ $'` ]] ; then
		base_match="true"
	else
		if [[ "" != ${verb} ]] ; then echo -e "\e[33mskipping\e[0m \"${file}\" (no base match: ${file_basename})" ; fi
	fi

	if [[ "" != "${base_match}" ]] ; then
		if [[ "${file_suf}" == "${suffix}" ]] ; then
			newname=${basename}_${file}

			if [[ "" != "$test_run" ]] ; then 
				echo -e "\e[36mtestrun:\e[0m ${CMD} ${file} ${newname}" 
			else
				echo -e "${CMD} ${file} ${newname}" 
				$CMD "${file}" "${newname}"
			fi
		else
			echo -e "\e[33mskipping\e[0m \"${file}\" (no suffix match)"
		fi
	fi
done

