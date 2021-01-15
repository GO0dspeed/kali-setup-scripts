#!/bin/bash

# Kali Linux deployment script - perform initial setup on a new kali linux box

# ensure sudo
echo "prompting for sudo password..."

if sudo -v; then
	while true; do sudo -n true; sleep 60; kill -o "$$" || exit; done 2>/dev/null &
		echo "Sudo Credentials updated"
else
	echo "Failed to obtain sudo credentials"
fi

# update apt repositories
echo "Updating apt repos"
apt-get update

# Generate SSH Key

echo "Generating SSH Key"
ssh-keygen -q -N ""

# Install VS Code
echo "Installing VS Code"
apt-get install -y snapd && snap install --classic code

# Install C2 Frameworks (Covenant and Merlin)
echo "Beginning installation of Covenant and Merlin for C2..."
echo "Installing .NET Core 3.1"
wget -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg &&
	mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ &&
	wget https://packages.microsoft.com/config/debian/9/prod.list && 
	mv prod.list /etc/apt/sources.list.d/microsoft-prod.list && 
	chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg&& 
	chown root:root /etc/apt/sources.list.d/microsoft-prod.list 
sudo apt-get install -y apt-transport-https &&
	sudo apt-get update && 
	sudo apt-get install -y dotnet-sdk-5.0

echo "Cloning Covenant to /opt/"
cd /opt/ && 
	git clone --recurse-submodules https://github.com/cobbr/Covenant

echo "Installing Merlin"
cd /opt/ &&
	mkdir merlin &&
	cd merlin &&
	wget https://github.com/Ne0nd0g/merlin/releases/download/v0.9.1-beta/merlinServer-Linux-x64.7z &&
	7z x merlinServer-Linux-x64.7z -pmerlin
