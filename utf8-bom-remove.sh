#!/bin/bash

UTF8_BOM="$(echo -n -e '\0357\0273\0277')"
sed -e "1s/^$UTF8_BOM//" "$@"
