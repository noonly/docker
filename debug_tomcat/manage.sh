#! /bin/bash

if [ -f "/tmp/project.conf" ]; then
context=`cat /tmp/project.conf`
if [ "_$context" != '_ok' ]; then
/usr/local/tomcat/bin/catalina.sh stop
/usr/local/tomcat/bin/catalina.sh run
else
/usr/local/tomcat/bin/catalina.sh stop
fi
else
echo "Temp file not existed"
fi
