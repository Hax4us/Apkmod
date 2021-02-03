#!/bin/sh

KEYTOOL="/usr/lib/jvm/java-1.8-openjdk/bin/keytool"
JARSIGNER="/usr/lib/jvm/java-1.8-openjdk/bin/jarsigner"

if [ ! -f $HOME/apkmod.keystore ]; then
    $KEYTOOL -noprompt -dname "CN=mqttserver.ibm.com, OU=ID, O=IBM, L=Hursley, S=Hants, C=GB" -storepass hax4us -genkey -v -keystore $HOME/apkmod.keystore -alias hax4us -keyalg RSA -validity 10000 -keypass hax4us
fi

exec $JARSIGNER "$@"
