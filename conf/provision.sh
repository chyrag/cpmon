#!/bin/bash

# fix for bug: stdin: is not a tty
# https://github.com/mitchellh/vagrant/issues/1673
sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

# Add tor repos to APT sources
apt-get install -y -qq apt-transport-https
echo "deb https://deb.torproject.org/torproject.org buster main" > /etc/apt/sources.list.d/tor.list
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

# Update packages
apt-get -yqq update
apt-get -yqq dist-upgrade -y
apt-get -yqq autoremove -y

# Install tor
apt-get -yqq install tor deb.torproject.org-keyring
apt-get clean

# Copy configuration files
cp -av /vagrant/conf/tor/* /etc/tor/

# Restart tor
service tor restart

# Link scripts
ln -s /vagrant/scripts /home/vagrant/
