#!/bin/bash
pidfile="dev/resources/database.pid"
PID=`cat ${pidfile}`
rm $pidfile
kill $PID
