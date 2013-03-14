#!/bin/bash
pidfile="test/resources/database.pid"
PID=`cat ${pidfile}`
rm $pidfile
kill $PID
