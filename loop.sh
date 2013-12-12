#!/bin/bash

while true
do
	date '+%Y-%m-%dT%H-%M-%S: ' | tr -d '\012'
	"$@"
	sleep 2
done
