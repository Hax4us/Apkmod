#!/bin/sh
javaOpts="-Xmx512M -Dfile.encoding=utf-8"
exec java $javaOpts -jar /opt/apktool.jar "$@"
