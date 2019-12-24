#!/bin/sh
JAVA="/usr/lib/jvm/java-1.8-openjdk/bin/java"
javaOpts="-Xmx512M -Dfile.encoding=utf-8"
exec $JAVA $javaOpts -jar /opt/apktool.jar "$@"
