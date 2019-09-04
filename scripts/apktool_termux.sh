#!/data/data/com.termux/files/usr/bin/sh
unset LD_PRELOAD
args="$@"
comnd="apktool $args"
exec proot --link2symlink -0 -r ${PREFIX}/share/TermuxAlpine/ -b /dev/ -b /sys/ -b /proc/ -b /sdcard -b $HOME -w $HOME /usr/bin/env HOME=/root TERM="$TERM" LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/sh --login -c "$comnd"
