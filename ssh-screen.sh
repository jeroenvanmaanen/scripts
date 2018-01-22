#!/bin/bash

ssh "$@" -t screen -R -D -T screen-256color bash -i -l