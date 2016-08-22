#!/bin/bash

FILE="$1"

sed -e '/^[^ ]/s/^//' "${FILE}" | tr '\002\012' '\012\002' | sed -e 's/ //g' | tr -d '\002' | sed -e "s;^;${FILE}: ;"
