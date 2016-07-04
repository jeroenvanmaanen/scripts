#!/bin/bash

docker-machine ssh default sudo mkdir -p /Volumes
docker-machine ssh default sudo mount -t vboxsf Volumes /Volumes
