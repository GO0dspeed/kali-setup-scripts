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
sudo apt-get install -y snapd > /dev/null 2>&1
echo "Ensuring that snapd is started"
sudo systemctl start snapd
sudo snap install --classic code
sudo systemctl start apparmor

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
sudo apt-get install -y apt-transport-https > /dev/null 2>&1 &&
	sudo apt-get update > /dev/null 2>&1 && 
	sudo apt-get install -y dotnet-sdk-3.1 > /dev/null 2>&1
sudo apt-get update > /dev/null 2>&1 &&
	sudo apt-get install -y aspnetcore-runtime-3.1 > /dev/null 2>&1

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
		cd merlin &&
		sudo wget https://github.com/Ne0nd0g/merlin/releases/download/v1.0.1/merlinServer-Linux-x64.7z &&
		sudo 7z x merlinServer-Linux-x64.7z -p merlin
fi

# Install reverse engineering framework components (Ghidra)
echo "Installing Ghidra"
if [[ -d /opt/ghidra_10.0.1_PUBLIC ]]
then
	echo "Ghidra is already installed"
else
	cd /opt/ &&
		sudo apt-get install -y openjdk-11-jdk &&
		sudo wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.0.1_build/ghidra_10.0.1_PUBLIC_20210708.zip &&
		sudo unzip ghidra_9.2.4_PUBLIC_20210427 > /dev/null 2>&1
fi

# Install privesc checking scripts
echo "Installing Privilege Escalation Awesome Script Suite"
if [[ -d /opt/privilege-escalation-awesome-scripts-suite ]]
then
	echo "PEAS is already installed"
else
	cd /opt/ &&
		sudo git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git
fi

# Install gobuster
echo "Installing GoBuster"
if [[ gobuster -v ]]
then
	echo "GoBuster is already installed"
else
	sudo apt-get install -y gobuster > /dev/null 2>&1
fi

# Install docker
echo "Installing Docker"
if [[ docker -v ]]
then
	echo "Docker already installed"
else
	sudo apt-get install -y docker.io > /dev/null 2>&1
fi

# Install docker compose
if [[ docker-compose -v ]]
then
	echo "Docker compose already installed"
else
	sudo apt-get install -y docker-compose > /dev/null 2>&1
fi

# Install rlwrap
echo "Installing rlwrap"
if [[ rlwrap ]]
then
	echo "RLWRAP already installed"
else
	sudo apt-get install -y rlwrap > /dev/null 2>&1
fi

# Install evil-winrm
if [[ evil-winrm -v ]]
then
	echo "Evil-winrm is installed"
else
	sudo gem install -y evil-winrm > /dev/null 2>&1
fi

# Intall Bloodhound and Neo4j
# Neo4j
echo "Installing Bloodhound"
if [[ neo4j -v ]]
then
	echo "Neo4j already installed, installing Bloodhound GUI"
else
	sudo apt-get install -y neo4j > /dev/null 2>&1
fi

# Bloodhound
if [[ bloodhound -v ]]
then
	echo "Bloodhound GUI is installed"
else
	sudo apt-get install -y bloodhound > /dev/null 2>&1
fi

# Install Ghostwriter
if [[ docker -ps | grep ghostwriter_ ]]
then
	echo "Ghostwriter is installed and running in Docker"
else
	echo "Cloning Ghostwriter repo"
	cd /opt/ &&
		git clone https://github.com/GhostManager/Ghostwriter.git
	sudo mkdir /opt/Ghostwriter/.envs
	sudo cp -r /opt/Ghostwriter/.envs_template/* /opt/Ghostwriter/.envs
	echo "Starting docker containers"
	docker-compose -f /opt/Ghostwriter/local.yml stop
	docker-compose -f /opt/Ghostwriter/local.yml rm -f
	docker-compose -f /opt/Ghostwriter/local.yml build
	docker-compose -f /opt/Ghostwriter/local.yml up -d
	echo "Waiting 60 seconds"
	sleep 60
	echo "Starting Ghostwriter database"
	docker-compose -f local.yml run --rm django /seed_data
fi
