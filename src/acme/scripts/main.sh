#!/bin/bash

# SIGTERM-handler this funciton will be executed when the container receives the SIGTERM signal (when stopping)
term_handler(){
   echo "*********Stopping ACME*********"
   exit 0
}

# Setup signal handlers
trap 'term_handler' SIGTERM

echo "*********Starting ACME*********"

# Running something in foreground, otherwise the container will stop
while true
do
   /bin/bash gencert.sh & wait
done