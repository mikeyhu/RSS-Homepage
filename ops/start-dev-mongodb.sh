#!/bin/bash
mongod --pidfilepath dev/resources/database.pid --nssize 1 --smallfiles --noprealloc --dbpath dev/resources/database/ > dev/log/database.log &