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
sudo apt-get update 

# Install VS Code
echo "Checking for VS Code install"
if command -v code-oss 
then
	echo "Code is already installed"
else
	echo "Installing Code-OSS"
	sudo apt-get install -y code-oss 
fi

# Install C2 Frameworks (Covenant and Merlin)
echo "Checking for .NET Core 3.1 install"
if [[ -f /etc/apt/trusted.gpg.d/microsoft.asc.gpg && /etc/apt/sources.list.d/microsoft-prod.list ]]
then
	echo "Microsoft package signing key already installed..."
else
	sudo wget -O - https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor > microsoft.asc.gpg 
	sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
	sudo wget https://packages.microsoft.com/config/debian/9/prod.list 
	sudo mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
	sudo chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
	sudo chown root:root /etc/apt/sources.list.d/microsoft-prod.list
fi
	sudo apt-get install -y apt-transport-https 
	sudo apt-get update 
	sudo apt-get install -y dotnet-sdk-3.1 
	sudo apt-get update 
	sudo apt-get install -y aspnetcore-runtime-3.1 

echo "Checking for Covenant in /opt/"
if [[ -d /opt/Covenant ]]
then
	echo "Covenant already installed"
else
	echo "Cloning Covenant"
	sudo git clone --recurse-submodules https://github.com/cobbr/Covenant /opt/Covenant 
fi

echo "Checking for Merlin install"
if [[ -d /opt/merlin ]]
then
	echo "Merlin already installed"
else
	echo "Installing Merlin"
	sudo mkdir /opt/merlin
	sudo wget -P /opt/ https://github.com/Ne0nd0g/merlin/releases/download/v1.0.1/merlinServer-Linux-x64.7z 
	sudo 7z x /opt/merlinServer-Linux-x64.7z -o/opt/merlin -pmerlin 
fi

# Install Mythic
echo "Checking for Mythic install"
if [[ -d /opt/Mythic ]]
then
	echo "Mythic already installed"
else
	echo "Cloning Mythic"
	sudo git clone https://github.com/its-a-feature/Mythic.git /opt/Mythic 
fi

# Install reverse engineering framework components (Ghidra)
echo "Checking for Ghidra install"
if [[ -d /opt/ghidra_10.0.1_PUBLIC_20210708 ]]
then
	echo "Ghidra is already installed"
else
	echo "Installing Ghidra"
	sudo apt-get install -y openjdk-11-jdk 
	sudo wget -P /opt/ https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.0.1_build/ghidra_10.0.1_PUBLIC_20210708.zip 
	sudo unzip /opt/ghidra_10.0.1_PUBLIC_20210708.zip -d /opt/ghidra_10.0.1_PUBLIC_20210708 
fi

# Install privesc checking scripts
echo "Checking for Privilege Escalation Awesome Script Suite install"
if [[ -d /opt/privilege-escalation-awesome-scripts-suite ]]
then
	echo "PEAS is already installed"
else
	echo "Installing PEAS"
	sudo git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git /opt/privilege-escalation-awesome-scripts-suite 
fi

# Install gobuster
echo "Checking for GoBuster install"
if command -v gobuster 
then
	echo "GoBuster is already installed"
else
	echo "Installing GoBuster"
	sudo apt-get install -y gobuster 
fi

# Install docker
echo "Checking for Docker install"
if command -v docker 
then
	echo "Docker already installed"
else
	echo "Installing Docker"
	sudo apt-get install -y docker.io 
fi

# Install docker compose
echo "Checking for docker compose install"
if command -v docker-compose 
then
	echo "Docker compose already installed"
else
	echo "Installing Docker Compose"
	sudo apt-get install -y docker-compose 
fi

# Install rlwrap
echo "Checking for rlwrap install"
if command-v rlwrap 
then
	echo "RLWRAP already installed"
else
	echo "Installing RLWRAP"
	sudo apt-get install -y rlwrap 
fi

# Install evil-winrm
echo "Checking for Evil-winrm install"
if command-v evil-winrm 
then
	echo "Evil-winrm is installed"
else
	echo "Installing Evil-winrm"
	sudo gem install evil-winrm 
fi

# Intall Bloodhound and Neo4j
# Neo4j
echo "Checking for neo4j install"
if command -v neo4j 
then
	echo "Neo4j already installed."
else
	echo "Installing Neo4j"
	sudo apt-get install -y neo4j 
fi

# Bloodhound
echo "Checking for Bloodhound install"
if command -v bloodhound 
then
	echo "Bloodhound GUI is installed"
else
	echo "Installing Bloodhound"
	sudo apt-get install -y bloodhound 
fi

# Install Ghostwriter
echo "Checking for Ghostwriter install"
if [[ -d /opt/Ghostwriter ]]
then
	echo "Ghostwriter is installed"
else
	echo "Cloning Ghostwriter repo"
	sudo git clone https://github.com/GhostManager/Ghostwriter.git /opt/Ghostwriter 
	sudo mkdir /opt/Ghostwriter/.envs
	sudo cp -r /opt/Ghostwriter/.envs_template/.production /opt/Ghostwriter/.envs
	sudo cp -r /opt/Ghostwriter/.envs_template/.local /opt/Ghostwriter/.envs
	echo "Starting docker containers"
	sudo docker-compose -f /opt/Ghostwriter/local.yml stop 
	sudo docker-compose -f /opt/Ghostwriter/local.yml rm -f 
	sudo docker-compose -f /opt/Ghostwriter/local.yml build 
	sudo docker-compose -f /opt/Ghostwriter/local.yml up -d 
	echo "Waiting 60 seconds"
	sleep 60
	echo "Starting Ghostwriter database"
	sudo docker-compose -f local.yml run --rm django /seed_data 
fi

echo "Installation complete!"
