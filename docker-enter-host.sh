#!/bin/bash

docker run -it --pid=host --privileged debian:jessie nsenter -t 1 -m -p -n
