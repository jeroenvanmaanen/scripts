FROM    ubuntu:xenial

RUN     apt-get update

# Install python and evernote development kit
RUN     apt-get install -q -y  --no-install-recommends python
RUN     apt-get install -q -y  --no-install-recommends python-setuptools
RUN     apt-get install -q -y  --no-install-recommends python-pip
RUN	pip install --upgrade pip
RUN     pip install evernote
