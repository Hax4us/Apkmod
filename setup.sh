#!/data/data/com.termux/files/usr/bin/sh

#colors 
red='\033[1;31m'  
yellow='\033[1;33m'
reset='\033[0m'

ALPINEDIR="${PREFIX}/share/TermuxAlpine"
BINDIR="${PREFIX}/bin"

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
			printf "${red}[!] Wrong input${reset}"
			exit 1
		fi
	fi
	if [ "${noinstall}" = "no" ]; then
		wget https://raw.githubusercontent.com/Hax4us/TermuxAlpine/master/TermuxAlpine.sh
		bash TermuxAlpine.sh
	fi
	mkdir ${ALPINEDIR}/root/.bind
	cat <<EOF | startalpine
	apk add openjdk8-jre
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
		x86)
			ARCH=x86
			;;
		x86_64)
			ARCH=x86_64
			;;
		*)
			printf "your device is not supported yet"
			exit 1
			;;
	esac
	aapturl=https://github.com/hax4us/Apkmod/raw/master/aapt/${ARCH}/aapt
	wget ${aapturl} -O ${ALPINEDIR}/usr/bin/aapt
	apktoolurl=https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.0.jar
	wget ${apktoolurl} -O ${ALPINEDIR}/opt/apktool.jar
	wget https://github.com/hax4us/Apkmod/raw/master/apkmod.sh -O ${BINDIR}/apkmod
	chmod +x ${BINDIR}/apkmod
}

install_scripts() {
	for script in apktool_termux.sh apktool_alpine.sh apk.rb; do
		wget https://github.com/hax4us/Apkmod/raw/master/scripts/${script}
	done
	mv apktool_termux.sh ${BINDIR}/apktool && chmod +x ${BINDIR}/apktool
	mv apktool_alpine.sh ${ALPINEDIR}/bin/apktool && chmod +x ${ALPINEDIR}/bin/apktool
	if [ -d ${HOME}/metasploit-framework ]; then
		mv apk.rb ${HOME}/metasploit-framework/lib/msf/core/payload/
	elif [ -d ${PREFIX}/opt/metasploit-framework ]; then
		mv apk.rb ${PREFIX}/opt/metasploit-framework/lib/msf/core/payload/
	else
		printf "${red}[!] Metasploit is not installed${reset}"
	fi
}

termux-wake-lock
setup_alpine
install_deps
install_scripts
termux-wake-unlock
