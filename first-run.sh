#!/bin/bash

echo "Installing Docker!"

sudo dnf -y install yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo systemctl start docker
sudo systemctl enable docker

