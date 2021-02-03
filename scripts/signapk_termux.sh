#!/data/data/com.termux/files/usr/bin/sh
unset LD_PRELOAD
args="$@"
comnd="signapk $args"
exec proot --link2symlink -0 -r ${PREFIX}/share/apkmod/ -b /dev/ -b /sys/ -b /proc/ -b /sdcard -b /storage -b ${HOME} -b ${TMPDIR} -b ${PREFIX}/share -w $HOME /usr/bin/env HOME=/root PREFIX=/usr SHELL=/bin/sh TERM="$TERM" LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin LD_LIBRARY_PATH=/usr/lib /bin/sh --login -c "$comnd"
