#!/bin/bash

VBoxManage list vms \
	| sed -e 's/^"//' -e 's/".*//' \
	| tr '\012' '\000' \
	| xargs -0 -I + bash -c "VBoxManage showvminfo --machinereadable '+' | sed -e 's/=/|/' -e 's:^:+|:'"
