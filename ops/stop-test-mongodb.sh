#!/bin/bash
pidfile="test/resources/database.pid"
if [ -f $pidfile ] 
	then
	PID=`cat ${pidfile}`
	rm $pidfile
	kill $PID
fi
