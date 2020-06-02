#!/data/data/com.termux/files/usr/bin/bash
addprofile()
{
	cat > ${PREFIX}/share/apkmod/etc/profile <<- EOM
	export CHARSET=UTF-8
	export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
	export PAGER=less
	export PS1='[\u@\h \W]\\$ '
	umask 022
	for script in /etc/profile.d/*.sh ; do
	if [ -r \$script ] ; then
	. \$script
	fi
	done
	EOM
}

addmotd() {
	cat > ${PREFIX}/share/TermuxAlpine/etc/profile.d/motd.sh  <<- EOM
	printf "\n\033[1;34mWelcome to Alpine Linux in Termux!  Enjoy!\033[0m\033[1;34m
	Chat:    \033[0m\033[mhttps://gitter.im/termux/termux/\033[0m\033[1;34m
		Help:    \033[0m\033[34minfo <query> \033[0m\033[mand \033[0m\033[34mman <query> \033[0m\033[1;34m
			Portal:  \033[0m\033[mhttps://wiki.termux.com/wiki/Community\033[0m\033[1;34m

		Install a package: \033[0m\033[34mapk add <package>\033[0m\033[1;34m
			More  information: \033[0m\033[34mapk --help\033[0m\033[1;34m
				Search   packages: \033[0m\033[34mapk search <query>\033[0m\033[1;34m
					Upgrade  packages: \033[0m\033[34mapk upgrade \n\033[0m \n"
						EOM
}

updrepos() {
	cp ${PREFIX}/share/TermuxAlpine/etc/apk/repositories ${PREFIX}/share/TermuxAlpine/etc/apk/repositories.bak
	cat > ${PREFIX}/share/TermuxAlpine/etc/apk/repositories <<- EOM
	http://dl-cdn.alpinelinux.org/alpine/latest-stable/main/
	http://dl-cdn.alpinelinux.org/alpine/latest-stable/community/
	http://dl-cdn.alpinelinux.org/alpine/edge/testing/
	EOM
}
# thnx to @j16180339887 for DNS picker 
addresolvconf ()
{
	printf "nameserver 8.8.8.8\nnameserver 8.8.4.4" > ${PREFIX}/share/apkmod/etc/resolv.conf
}
android=$(getprop ro.build.version.release)
addprofile
if [ "${1}" = "--add-motd" ]; then
	addmotd
fi
if [ ${android%%.*} -ge 8 ]; then
	addresolvconf
fi
#updrepos
