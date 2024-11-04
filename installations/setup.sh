
hostnamectl set-hostname buildmaster
#exec bash 
yum update -y
yum install wget vim tar make unzip git -y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
# Add required dependencies for the jenkins package
sudo yum install fontconfig java-17-openjdk-devel -y
sudo yum install jenkins -y
sudo systemctl daemon-reload
systemctl start jenkins 
systemctl status jenkins --no-pager

# Configure Firewall
echo "Configuring firewall..."
firewall-cmd --permanent --add-port=8080/tcp 
firewall-cmd --reload 

echo "Setting JAVA_HOME and updating PATH..."
{
  printf "\n\n\n\n"  # Four blank lines
  echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk'
  echo 'export PATH=$JAVA_HOME/bin:$PATH'
  echo 'export PATH=$PATH:/usr/bin/git'
  echo 'export PATH=$PATH:/usr/bin/trivy'
  echo 'export M2_HOME=/opt/maven'
  echo 'export PATH=$PATH:/opt/maven/bin'
} >> ~/.bashrc
# Maven Install and setting path
cd /opt 
wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
tar -xvf apache-maven-3.9.9-bin.tar.gz
mv apache-maven-3.9.9 maven 
# Docker Install and setting path
yum update -y
yum install yum-utils device-mapper-persistent-data lvm2 -y
yum-config-manager --add-repo  https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce -y 
systemctl start docker 
systemctl enable docker

# Trivy Install and Setting Path
cat << EOF | sudo tee -a /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://aquasecurity.github.io/trivy-repo/rpm/public.key
EOF
sudo yum -y update
sudo yum -y install trivy
trivy --version
#updating .Bashrc File
source ~/.bashrc
# echo "Checking All Versions of Packages"
java --version
git --version
docker version 
trivy --version 
mvn --version 
