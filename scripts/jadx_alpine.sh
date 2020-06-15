#!/bin/sh

APP_HOME=/usr/lib/jadx
CLASSPATH=$APP_HOME/lib/jadx-cli-1.1.0.jar:$APP_HOME/lib/jadx-core-1.1.0.jar:$APP_HOME/lib/dx-1.16.jar:$APP_HOME/lib/android-29-clst.jar:$APP_HOME/lib/android-29-res.jar:$APP_HOME/lib/logback-classic-1.2.3.jar:$APP_HOME/lib/slf4j-api-1.7.29.jar:$APP_HOME/lib/baksmali-2.3.4.jar:$APP_HOME/lib/smali-2.3.4.jar:$APP_HOME/lib/util-2.3.4.jar:$APP_HOME/lib/jcommander-1.78.jar:$APP_HOME/lib/asm-7.2.jar:$APP_HOME/lib/annotations-18.0.0.jar:$APP_HOME/lib/gson-2.8.6.jar:$APP_HOME/lib/dexlib2-2.3.4.jar:$APP_HOME/lib/guava-28.1-jre.jar:$APP_HOME/lib/logback-core-1.2.3.jar:$APP_HOME/lib/antlr-runtime-3.5.2.jar:$APP_HOME/lib/stringtemplate-3.2.1.jar:$APP_HOME/lib/failureaccess-1.0.1.jar:$APP_HOME/lib/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar:$APP_HOME/lib/jsr305-3.0.2.jar:$APP_HOME/lib/checker-qual-2.8.1.jar:$APP_HOME/lib/error_prone_annotations-2.3.2.jar:$APP_HOME/lib/j2objc-annotations-1.3.jar:$APP_HOME/lib/animal-sniffer-annotations-1.18.jar:$APP_HOME/lib/antlr-2.7.7.jar

DEFAULT_JVM_OPTS='"-Xms128M" "-Xmx4g" "-XX:+UseG1GC"'

exec java -classpath $CLASSPATH jadx.cli.JadxCLI "$@"
