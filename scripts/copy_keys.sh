#!/bin/bash
# Copy Vagrant private keys to local SSH directory
# Runs automatically after vagrant up via Vagrant trigger
cp /vagrant/.vagrant/machines/nginx/virtualbox/private_key /home/vagrant/.ssh/nginx_key
cp /vagrant/.vagrant/machines/web1/virtualbox/private_key /home/vagrant/.ssh/web1_key
cp /vagrant/.vagrant/machines/web2/virtualbox/private_key /home/vagrant/.ssh/web2_key
cp /vagrant/.vagrant/machines/database/virtualbox/private_key /home/vagrant/.ssh/database_key
cp /vagrant/.vagrant/machines/monitor/virtualbox/private_key /home/vagrant/.ssh/monitor_key
chmod 600 /home/vagrant/.ssh/nginx_key
chmod 600 /home/vagrant/.ssh/web1_key
chmod 600 /home/vagrant/.ssh/web2_key
chmod 600 /home/vagrant/.ssh/database_key
chmod 600 /home/vagrant/.ssh/monitor_key
echo "=== SSH keys copied ==="