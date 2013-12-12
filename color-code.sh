#!/bin/bash

sed -E \
	-e '/^([+]|[[] (WARN|INFO|N?OK) ])/!b' \
	-e "s/\$/$(tput setaf 0)/" \
	-e '/^[[] (WARN|NOK) ]/b warning' \
	-e '/^[[] INFO ]/b info' \
	-e '/^[[] OK ]/b ok' \
	-e "s/^/$(tput setaf 7)/" \
	-e b \
	-e ':warning' \
	-e "s/^/$(tput setaf 1)/" \
	-e b \
	-e ':info' \
	-e "s/^/$(tput setaf 4)/" \
	-e b \
	-e ':ok' \
	-e "s/^/$(tput setaf 2)/" \
	"$@"
