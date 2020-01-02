#!/data/data/com.termux/files/usr/bin/sh

#colors 
red='\033[1;31m'  
yellow='\033[1;33m'
reset='\033[0m'

ALPINEDIR="${PREFIX}/share/TermuxAlpine"
BINDIR="${PREFIX}/bin"
LIBDIR="${ALPINEDIR}/usr/lib"

setup_alpine() {
	noinstall="no"
	if [ -d ${ALPINEDIR} ]; then
		printf "${red}[!] ${yellow}Alpine is already installed\nDo you want to reinstall ? (type \"y\" for yes or \"n\" for no) :${reset} "   
		read choice
		if [ "${choice}" = "y" ]; then
			rm -rf ${DESTINATION}
		elif [ "${choice}" = "n" ]; then
			noinstall="yes"
		else
			printf "${red}[!] Wrong input${reset}\n"
			exit 1
		fi
	fi
	if [ "${noinstall}" = "no" ]; then
		wget https://raw.githubusercontent.com/Hax4us/Apkmod/master/scripts/TermuxAlpine.sh -O TermuxAlpine.sh
		bash TermuxAlpine.sh
	fi
	mkdir ${ALPINEDIR}/root/.bind
    mkdir ${ALPINEDIR}/home/.framework
	cat <<EOF | startalpine
	apk add openjdk8-jre libbsd zlib expat libpng protobuf
EOF
}

install_deps() {
	for pkg in apksigner wget bc; do
		if [ ! -f ${BINDIR}/${pkg} ]; then
			apt install ${pkg} -y
		fi
	done
	case "$(uname -m)" in
		aarch64|armv8l)
			ARCH=aarch64
			;;
		arm|armv7l)
			ARCH=arm
			;;
		x86|i686)
			ARCH=x86
			;;
		x86_64)
			ARCH=x86_64
			;;
		*)
            printf "your device $(uname -m) is not supported yet"
			exit 1
			;;
	esac
	aapturl=https://github.com/hax4us/Apkmod/raw/master/aapt/${ARCH}/aapt.tar.gz
	wget ${aapturl} -O aapt.tar.gz && tar -xf aapt.tar.gz -C ${LIBDIR} && rm aapt.tar.gz
    for i in aapt aapt2; do
        mv ${LIBDIR}/android/${i} ${ALPINEDIR}/usr/bin
    done
	apktoolurl=https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.1.jar
	wget ${apktoolurl} -O ${ALPINEDIR}/opt/apktool.jar
	wget https://github.com/hax4us/Apkmod/raw/master/apkmod.sh -O ${BINDIR}/apkmod
	chmod +x ${BINDIR}/apkmod
    chmod +x ${ALPINEDIR}/usr/bin/aapt
    chmod +x ${ALPINEDIR}/usr/bin/aapt2
    rm -rf ~/.apkmod && mkdir -p ~/.apkmod
}

install_scripts() {
	for script in apktool_termux.sh apktool_alpine.sh apk.rb; do
		wget https://github.com/hax4us/Apkmod/raw/master/scripts/${script} -O ${script}
	done
	mv apktool_termux.sh ${BINDIR}/apktool && chmod +x ${BINDIR}/apktool
	mv apktool_alpine.sh ${ALPINEDIR}/bin/apktool && chmod +x ${ALPINEDIR}/bin/apktool
    if [ -d ${HOME}/metasploit-framework -a -d ${PREFIX}/opt/metasploit-framework ]; then
        printf "${red}[!] More than one metasploit detected , remove anyone from them to install Apkmod\n${reset}"
        exit 1
    elif [ -d ${HOME}/metasploit-framework ]; then
        msf_dir=${HOME}/metasploit-framework
		mv apk.rb ${msf_dir}/lib/msf/core/payload/
	elif [ -d ${PREFIX}/opt/metasploit-framework ]; then
        msf_dir=${PREFIX}/opt/metasploit-framework
		mv apk.rb ${msf_dir}/lib/msf/core/payload/
	else
		printf "${red}[!] Metasploit is not installed${reset}"
        exit 1
	fi
}

do_patches() {
    cd ${msf_dir}
    for i in "msfvenom" "lib/msf/core/payload_generator.rb"; do
        if [ ! -e "${i}.orig" ]; then
            cp ${i} ${i}.orig
        fi
    done
    busybox grep "#patched" msfvenom > /dev/null
    if [ $? -ne 0 ]; then
        line_num=$(busybox grep -n "help" msfvenom | cut -d ":" -f1)
        line_num=$((${line_num}-1))
        busybox awk -v "n=${line_num}" -v "s=\n\topt.on('--use-aapt2','Use aapt2 for recompiling') do\n\t\topts[:use_aapt2] = true\n\tend" '(NR==n) { print s } 1' msfvenom.orig > msfvenom
        if [ $? -eq 0 ]; then
            printf "#patched" >> msfvenom
        else
            printf "${red}[!] can't patch msfvenom\n${reset}"
            exit 1
        fi
    fi
    busybox grep "#patched" lib/msf/core/payload_generator.rb > /dev/null
    if [ $? -ne 0 ]; then
        line_num=$(busybox grep -n ":add_code" lib/msf/core/payload_generator.rb | head -n1 | cut -d ":" -f1)
        line_num=$((${line_num}-2))
        busybox awk -v "n=${line_num}" -v "s=\t# @\!attribute  use_aapt2\n\t#   @return [String] use aapt2 or not\n\tattr_accessor :use_aapt2" '(NR==n) { print s } 1' lib/msf/core/payload_generator.rb.orig > lib/msf/core/payload_generator.rb
        if [ $? -ne 0 ]; then
            printf "${red}[!] can't patch payload_generator.rb\n${reset}"
            exit 1
        fi
        line_num=$(busybox grep -n "@framework" lib/msf/core/payload_generator.rb | head -n1 | cut -d ":" -f1)
        line_num=$((${line_num}-2))
        busybox sed -i "${line_num}s/.*/\t@use_aapt2 = opts.fetch(:use_aapt2,false)/" lib/msf/core/payload_generator.rb
        if [ $? -ne 0 ]; then
            printf "${red}[!] can't patch payload_genereator.rb\n${reset}"
            exit 1
        fi
        line_num=$(busybox grep -n "apk_backdoor.backdoor_apk" lib/msf/core/payload_generator.rb | cut -d ":" -f1)
        busybox sed -i "${line_num}s/.*/\t\traw_payload = apk_backdoor.backdoor_apk(template, generate_raw_payload, use_aapt2)/" lib/msf/core/payload_generator.rb
        if [ $? -eq 0 ]; then
            printf "#patched" >> lib/msf/core/payload_generator.rb
        else
            printf "${red}[!] can't patch payload_generator.rb\n${reset}"
            exit 1
        fi
    fi
}

termux-wake-lock
setup_alpine
install_deps
install_scripts
do_patches
termux-wake-unlock
