#!/bin/bash
rm -rf test/resources/database/*
rm -rf test/log/database.log
mongod --port 27000 --pidfilepath test/resources/database.pid --nssize 1 --smallfiles --noprealloc --dbpath test/resources/database/ > test/log/database.log &