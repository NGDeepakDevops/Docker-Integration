#!/bin/bash

# Set the hostname
echo "Setting hostname to 'buildmaster'..."
hostnamectl set-hostname buildmaster

# Update system packages
echo "Updating system packages..."
yum update -y

# Install required packages
echo "Installing wget, vim, tar, make, unzip, and git..."
yum install wget vim tar make unzip git -y

# Add Jenkins repository
echo "Adding Jenkins repository..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Upgrade system and install Java
echo "Upgrading system and installing Java 17..."
yum upgrade -y
yum install fontconfig java-17-openjdk-devel -y

# Install Jenkins
echo "Installing Jenkins..."
yum install jenkins -y
systemctl daemon-reload
systemctl start jenkins
systemctl status jenkins --no-pager

# Configure firewall for Jenkins
echo "Configuring firewall to allow Jenkins (port 8080)..."
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload

# Set JAVA_HOME and update PATH
echo "Setting JAVA_HOME and updating PATH in .bashrc..."
{
  printf "\n\n\n\n"  # Four blank lines
  echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk'
  echo 'export PATH=$JAVA_HOME/bin:$PATH'
  echo 'export PATH=$PATH:/usr/bin/git'
  echo 'export PATH=$PATH:/usr/bin/trivy'
  echo 'export M2_HOME=/opt/maven'
  echo 'export PATH=$PATH:/opt/maven/bin'
} >> ~/.bashrc

# Install Maven
echo "Installing Maven..."
cd /opt
wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
tar -xvf apache-maven-3.9.9-bin.tar.gz
mv apache-maven-3.9.9 maven

# Install Docker
echo "Installing Docker..."
yum update -y
yum install yum-utils device-mapper-persistent-data lvm2 -y
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce -y
systemctl start docker
systemctl enable docker

# Install Trivy
echo "Installing Trivy..."
cat << EOF | sudo tee -a /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://aquasecurity.github.io/trivy-repo/rpm/public.key
EOF

yum -y update
yum -y install trivy

# Source the updated .bashrc
echo "Sourcing .bashrc to apply PATH updates..."
source ~/.bashrc

# Check installed versions
echo "Verifying installed versions..."
java --version
git --version
docker --version
trivy --version
mvn --version

echo "Script execution completed successfully."
