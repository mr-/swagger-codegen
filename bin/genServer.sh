#!/bin/bash

SCRIPT="$0"

while getopts s:d: opt; do
    case $opt in
    s)
        SOURCEFILE=$OPTARG
        ;;
    d)
        DESTDIR=$OPTARG

    esac
done
shift $((OPTIND - 1))

if [ ! -f "$SOURCEFILE" ]; then
    echo "File not found: $SOURCEFILE"
    exit
fi

if [ ! -d "$DESTDIR" ]; then
    echo "Invalid destination: $DESTDIR"
    exit
fi

while [ -h "$SCRIPT" ] ; do
  ls=`ls -ld "$SCRIPT"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    SCRIPT="$link"
  else
    SCRIPT=`dirname "$SCRIPT"`/"$link"
  fi
done

if [ ! -d "${APP_DIR}" ]; then
  APP_DIR=`dirname "$SCRIPT"`/..
  APP_DIR=`cd "${APP_DIR}"; pwd`
fi

cd $APP_DIR


# if you've executed sbt assembly previously it will use that instead.
export JAVA_OPTS="${JAVA_OPTS} -XX:MaxPermSize=256M -Xmx1024M -DloggerPath=conf/log4j.properties"
ags="$@ com.wordnik.swagger.codegen.Codegen -i $SOURCEFILE -l Standalone -o $DESTDIR"

echo "java -cp $APP_DIR/target/*:$APP_DIR/target/lib/* $ags"
java -cp $APP_DIR/target/*:$APP_DIR/target/lib/* $ags
