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
		wget https://raw.githubusercontent.com/Hax4us/TermuxAlpine/master/TermuxAlpine.sh
		bash TermuxAlpine.sh
	fi
	mkdir ${ALPINEDIR}/root/.bind
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
	wget ${aapturl} && tar -xf aapt.tar.gz -C ${LIBDIR} && rm aapt.tar.gz
    for i in aapt aapt2; do
        mv ${LIBDIR}/android/${i} ${ALPINEDIR}/usr/bin
    done
	apktoolurl=https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.0.jar
	wget ${apktoolurl} -O ${ALPINEDIR}/opt/apktool.jar
	wget https://github.com/hax4us/Apkmod/raw/master/apkmod.sh -O ${BINDIR}/apkmod
	chmod +x ${BINDIR}/apkmod
    chmod +x ${ALPINEDIR}/usr/bin/aapt
    chmod +x ${ALPINEDIR}/usr/bin/aapt2
}

install_scripts() {
	for script in apktool_termux.sh apktool_alpine.sh apk.rb; do
		wget https://github.com/hax4us/Apkmod/raw/master/scripts/${script}
	done
	mv apktool_termux.sh ${BINDIR}/apktool && chmod +x ${BINDIR}/apktool
	mv apktool_alpine.sh ${ALPINEDIR}/bin/apktool && chmod +x ${ALPINEDIR}/bin/apktool
	if [ -d ${HOME}/metasploit-framework ]; then
        metasploit="noinbuilt"
		mv apk.rb ${HOME}/metasploit-framework/lib/msf/core/payload/
	elif [ -d ${PREFIX}/opt/metasploit-framework ]; then
        metasploit="inbuilt"
		mv apk.rb ${PREFIX}/opt/metasploit-framework/lib/msf/core/payload/
	else
		printf "${red}[!] Metasploit is not installed${reset}"
        exit 1
	fi
}

do_patches() {
    if [ "${metasploit}" = "noinbuilt" ]; then
        VERSION=$(grep VERSION ~/metasploit-framework/lib/metasploit/framework/version.rb | head -n1 | sed -e 's/ /\n/g' | grep -E "[0-9]" | sed -e 's/"//g')
        cd ~/metasploit-framework
    elif [ "${metasploit}" = "inbuilt" ]; then
        VERSION=$(grep VERSION ${PREFIX}/opt/metasploit-framework/lib/metasploit/framework/version.rb | head -n1 | sed -e 's/ /\n/g' | grep -E "[0-9]" | sed -e 's/"//g')
        cd ${PREFIX}/opt/metasploit-framework
    fi
    if [ -z "$VERSION" ]; then
        printf "${red}[!] metasploit version can't be determined${reset}"
        exit 1
    fi
    for patch in msfvenom.patch payload_generator.rb.patch; do
        rm -f ${patch}
        wget https://github.com/hax4us/Apkmod/raw/master/patches/msf-${VERSION}/${patch}
    done
    patch -N --dry-run -i msfvenom.patch > /dev/null
    if [ $? -eq 0 ]; then
        patch -i msfvenom.patch
    fi
    patch -p0 -N --dry-run -i payload_generator.rb.patch > /dev/null
    if [ $? -eq 0 ]; then
        patch -p0 -i payload_generator.rb.patch
    fi
}

termux-wake-lock
setup_alpine
install_deps
install_scripts
do_patches
termux-wake-unlock
