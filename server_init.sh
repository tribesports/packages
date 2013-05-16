#!/bin/bash

set -e

if [[ -f "~vagrant/bootstrapped" ]]; then
  echo "Machine already bootstrapped, skipping..."
  exit 0
fi

cd /vagrant

apt-key add tribesports-pubkey.asc
sudo -u vagrant -H gpg --import tribesports-privkey.asc || true

cat /vagrant/keys/id_rsa.pub >> ~vagrant/.ssh/authorized_keys

# Upgrade the HECK out of things.
apt-get update
apt-get -y install aptitude
# Junk necessary to get a properly non-interactive upgrade
DEBIAN_FRONTEND=noninteractive aptitude -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" safe-upgrade
apt-get install -y ruby1.9.3 dpkg-dev

gem install fpm --no-ri --no-rdoc

touch ~vagrant/bootstrapped
