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
sudo apt-get update > /dev/null 2>&1

# Install VS Code
echo "Installing VS Code"
sudo apt-get install -y snapd 
sudo snap install --classic code

# Install C2 Frameworks (Covenant and Merlin)
echo "Beginning installation of Covenant and Merlin for C2..."
echo "Installing .NET Core 3.1"
if [[ -f /etc/apt/trusted.gpg.d/microsoft.asc.gpg && /etc/apt/sources.list.d/microsoft-prod.list ]]
then
	echo "Microsoft package signing key already installed..."
else
	sudo wget -O - https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor > microsoft.asc.gpg &&
		sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ &&
		sudo wget https://packages.microsoft.com/config/debian/9/prod.list && 
		sudo mv prod.list /etc/apt/sources.list.d/microsoft-prod.list && 
		sudo chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg&& 
		sudo chown root:root /etc/apt/sources.list.d/microsoft-prod.list 
fi
sudo apt-get install -y apt-transport-https &&
	sudo apt-get update > /dev/null 2>&1 && 
	sudo apt-get install -y dotnet-sdk-3.1
sudo apt-get update > /dev/null 2>&1 &&
	sudo apt-get install -y apt-transport-https &&
	sudo apt-get update > /dev/null 2>&1 &&
	sudo apt-get install -y aspnetcore-runtime-3.1

echo "Cloning Covenant to /opt/"
if [[ -d /opt/Covenant ]]
then
	echo "Covenant already installed"
else
	cd /opt/ && 
		sudo git clone --recurse-submodules https://github.com/cobbr/Covenant
fi

echo "Installing Merlin"
if [[ -d /opt/merlin ]]
then
	echo "Merlin already installed"
else
	cd /opt/ &&
		sudo mkdir merlin &&
		sudo cd merlin &&
		sudo wget https://github.com/Ne0nd0g/merlin/releases/download/v0.9.1-beta/merlinServer-Linux-x64.7z &&
		sudo 7z x merlinServer-Linux-x64.7z -pmerlin
fi
