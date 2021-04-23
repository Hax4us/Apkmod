#!/data/data/com.termux/files/usr/bin/sh

#colors 
red='\033[1;31m'  
yellow='\033[1;33m'
reset='\033[0m'

ALPINEDIR="${PREFIX}/share/apkmod"
BINDIR="${PREFIX}/bin"
LIBDIR="${ALPINEDIR}/usr/lib"

detect_os() {
	if [ -e $BINDIR/termux-info ]; then
		OS=TERMUX
		#AAPT="-a /usr/bin/aapt2"
	else
		grep kali /etc/os-release > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			OS=KALI
			AAPT="--use-aapt2"
		else
			printf "${red}[!] ${yellow}Unsupported system\n"
			exit 1
		fi
	fi
}

install_deps_kali() {
	printf "[*] Installing dependencies...\n"
	apt-get install metasploit-framework bc apktool default-jdk -y > /dev/null
	wget https://github.com/hax4us/Apkmod/raw/master/apkmod.sh -O $PREFIX/bin/apkmod && chmod +x $PREFIX/bin/apkmod
	printf "[*] Done\n"
}

setup_alpine() {
	if [ ! "$1" = "--without-alpine" ]; then
		wget https://raw.githubusercontent.com/Hax4us/Apkmod/master/scripts/TermuxAlpine.sh -O TermuxAlpine.sh
		bash TermuxAlpine.sh
	fi
	mkdir -p ${ALPINEDIR}/root/.bind
	cat <<EOF | apkmalpine
	apk add openjdk8 libbsd zlib expat libpng protobuf libunwind
EOF
}

install_deps() {
	for pkg in aapt apksigner wget bc busybox sed; do
		if [ ! -f ${BINDIR}/${pkg} ]; then
			apt install ${pkg} -y
		fi
	done
	case "$(getprop ro.product.cpu.abi)" in
		arm64-v8a)
			ARCH=aarch64
			;;
		armeabi|armeabi-v7a)
			ARCH=arm
			;;
		x86|i686)
			ARCH=x86
			;;
		x86_64)
			ARCH=x86_64
			;;
		*)
			printf "your device "$(uname -m)" is not supported yet"
			exit 1
			;;
	esac

	aapturl=https://github.com/Hax4us/Hax4us.github.io/blob/master/files/aapt/$ARCH/aapt.tar.gz?raw=true
	wget ${aapturl} -O aapt.tar.gz && tar -xf aapt.tar.gz -C ${LIBDIR} && rm aapt.tar.gz
	
    for i in aapt aapt2; do
		mv ${LIBDIR}/android/${i} ${ALPINEDIR}/usr/bin
	done

	apktoolurl=https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.5.0.jar
	wget ${apktoolurl} -O ${ALPINEDIR}/opt/apktool.jar
	wget https://github.com/hax4us/Apkmod/raw/master/apkmod.sh -O ${BINDIR}/apkmod
	chmod +x ${BINDIR}/apkmod
	chmod +x ${ALPINEDIR}/usr/bin/aapt
	chmod +x ${ALPINEDIR}/usr/bin/aapt2
	rm -rf ~/.apkmod && mkdir -p ~/.apkmod/framework
    wget https://github.com/hax4us/Apkmod/raw/master/apkmod.p12 -O ~/.apkmod/apkmod.p12
}

install_scripts() {
	for script in signapk_termux.sh signapk_alpine.sh apktool_termux.sh apktool_alpine.sh apk.rb jadx_termux.sh jadx_alpine.sh; do
		wget https://github.com/hax4us/Apkmod/raw/master/scripts/${script} -O ${script}
	done

	mv apktool_termux.sh ${BINDIR}/apktool && chmod +x ${BINDIR}/apktool
	mv apktool_alpine.sh ${ALPINEDIR}/bin/apktool && chmod +x ${ALPINEDIR}/bin/apktool
    mv jadx_termux.sh $BINDIR/jadx && chmod +x $BINDIR/jadx
    mv jadx_alpine.sh $ALPINEDIR/bin/jadx && chmod +x $ALPINEDIR/bin/jadx
    mv signapk_termux.sh $BINDIR/signapk && chmod +x $BINDIR/signapk
    mv signapk_alpine.sh $ALPINEDIR/bin/signapk && chmod +x $ALPINEDIR/bin/signapk

	if [ -d ${HOME}/metasploit-framework -a -d ${PREFIX}/opt/metasploit-framework ]; then
		printf "${red}[!] More than one metasploit detected ,\nremove anyone from them and reinstall Apkmod\notherwise apkmod will not work as expected${reset}"
	elif [ -d ${HOME}/metasploit-framework ]; then
		msf_dir=${HOME}/metasploit-framework
		mv apk.rb ${msf_dir}/lib/msf/core/payload/
	elif [ -d ${PREFIX}/opt/metasploit-framework ]; then
		msf_dir=${PREFIX}/opt/metasploit-framework
		mv apk.rb ${msf_dir}/lib/msf/core/payload/
	else
		printf "${red}[!] Metasploit is not installed hence -b ( bind ) option will not work${reset}"
        HAS_METASPLOIT="no"
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
        busybox awk -v "n=${line_num}" -v "s=\n\topt.on('--use-aapt','Use aapt for recompiling') do\n\t\topts[:use_aapt] = true\n\tend" '(NR==n) { print s } 1' msfvenom.orig > msfvenom
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
        busybox awk -v "n=${line_num}" -v "s=\t# @\!attribute  use_aapt\n\t#   @return [String] use aapt or not\n\tattr_accessor :use_aapt" '(NR==n) { print s } 1' lib/msf/core/payload_generator.rb.orig > lib/msf/core/payload_generator.rb
        if [ $? -ne 0 ]; then
            printf "${red}[!] can't patch payload_generator.rb\n${reset}"
            exit 1
        fi
        line_num=$(busybox grep -n "@framework" lib/msf/core/payload_generator.rb | head -n1 | cut -d ":" -f1)
        line_num=$((${line_num}-2))
        busybox sed -i "${line_num}s/.*/\t@use_aapt = opts.fetch(:use_aapt,false)/" lib/msf/core/payload_generator.rb
        if [ $? -ne 0 ]; then
            printf "${red}[!] can't patch payload_genereator.rb\n${reset}"
            exit 1
        fi
        line_num=$(busybox grep -n "apk_backdoor.backdoor_apk" lib/msf/core/payload_generator.rb | cut -d ":" -f1)
        busybox sed -i "${line_num}s/.*/\t\traw_payload = apk_backdoor.backdoor_apk(template, generate_raw_payload, use_aapt)/" lib/msf/core/payload_generator.rb
        if [ $? -eq 0 ]; then
            printf "#patched" >> lib/msf/core/payload_generator.rb
        else
            printf "${red}[!] can't patch payload_generator.rb\n${reset}"
            exit 1
        fi
    fi

    #sed -i "s#AAPT=.*#AAPT=\"$AAPT\"#" $BINDIR/apkmod
    if [ $OS = "KALI" ]; then
        sed -i "s#AAPT=.*#AAPT=\"$AAPT\"#" $BINDIR/apkmod
        sed -i s/"apktool b"/"apktool b --use-aapt2"/g /usr/share/metasploit-framework/lib/msf/core/payload/apk.rb
    fi
}

jadx() {
    JADXVER=1.1.0
    JADXURL=https://github.com/skylot/jadx/releases/download/v${JADXVER}/jadx-$JADXVER.zip
    wget $JADXURL
    mkdir -p $ALPINEDIR/usr/lib/jadx
    unzip jadx-$JADXVER.zip -d $ALPINEDIR/usr/lib/jadx
}

##################
#  MAIN DRIVER   #
##################

detect_os

if [ $OS = "TERMUX" ]; then
	termux-wake-lock
	# Temporary check for alpine version 
	# so that if user has already installed
	# TermuxAlpine then check if this alpine 
	# was installed by apkmod or not.
	#if [ -d $PREFIX/share/TermuxAlpine ]; then
	#	if [ "$(cat $PREFIX/share/TermuxAlpine/etc/alpine-release)" = "3.10.2" ]; then
	#		mv $PREFIX/share/TermuxAlpine $ALPINEDIR
	#	fi
	#fi

	setup_alpine "$1"
	install_deps
	install_scripts
	jadx
	termux-wake-unlock
    if [ ! "$HAS_METASPLOIT" = "no" ]; then
        do_patches
    fi
else
	install_deps_kali
    do_patches_kali
fi
