#! /bin/bash
process=`ps -ef | grep tomcat | grep -v "grep"`
if [ -f "/tmp/project.conf" ]; then
	context=`cat /tmp/project.conf`
	if [ "_$context" != '_ok' ]; then
	#/usr/local/tomcat/bin/catalina.sh stop
		if [ "_$process" == "_" ]; then
			/usr/local/tomcat/bin/catalina.sh run
		fi
	else
		if [ "_$process" != "_" ]; then
			/usr/local/tomcat/bin/catalina.sh stop
		fi
	fi
else
	echo "Temp file not existed"
fi
