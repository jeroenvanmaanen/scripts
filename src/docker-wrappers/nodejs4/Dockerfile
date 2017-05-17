FROM    centos:centos7

RUN	yum update -y

# Install Node.js and npm
RUN     curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -
RUN     yum install -y nodejs

# Install developer tools
RUN	yum install -y gcc-c++ make
