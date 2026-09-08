#!/bin/bash

set -e

echo "======================================"
echo "Starting Jenkins installation"
echo "======================================"

# --------------------------------------------------
# 1. Update system
# --------------------------------------------------

sudo apt-get update -y

# --------------------------------------------------
# 2. Install Java 21
# --------------------------------------------------

echo "Installing Java 21..."

sudo apt-get install -y fontconfig openjdk-21-jre

echo "Java version:"
java -version

# --------------------------------------------------
# 3. Install Jenkins
# --------------------------------------------------

echo "Installing Jenkins..."

sudo mkdir -p /etc/apt/keyrings

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y

sudo apt-get install -y jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Jenkins status:"
sudo systemctl status jenkins --no-pager

 # 4.Install Docker
# --------------------------------------------------

echo "======================================"
echo "Installing Docker"
echo "======================================"

# Update packages
sudo apt-get update -y

# Install prerequisites
sudo apt-get install -y \
    ca-certificates \
    curl

# Create Docker keyring directory
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker GPG key
sudo curl -fsSL \
    https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

# Remove old Docker repositories
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/sources.list.d/docker.sources

# Detect Ubuntu version automatically
UBUNTU_CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

echo "Ubuntu codename: ${UBUNTU_CODENAME}"

# Add Docker repository
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME}
Components: stable
Architectures: amd64
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Update repository information
sudo apt-get update -y

# Verify Docker package
echo "Checking Docker package..."
apt-cache policy docker-ce

# Install Docker
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Enable Docker
sudo systemctl enable docker

# Start Docker
sudo systemctl start docker

# Verify Docker
echo "Docker service status:"
sudo systemctl --no-pager status docker || true

echo "Docker version:"
sudo docker --version

echo "Docker Compose version:"
sudo docker compose version
# --------------------------------------------------
# 5. Install SonarQube
# --------------------------------------------------

echo "======================================"
echo "Installing SonarQube"
echo "======================================"

sudo docker pull sonarqube:lts-community

sudo docker run -d --name sonarqube \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:lts-community


echo "SonarQube container:"
sudo docker ps

# --------------------------------------------------
# 7. Install Trivy
# --------------------------------------------------

echo "======================================"
echo "Installing Trivy"
echo "======================================"

sudo apt-get install -y \
    wget \
    gnupg

sudo rm -f /etc/apt/sources.list.d/trivy.list
sudo rm -f /etc/apt/sources.list.d/trivy.sources
sudo rm -f /usr/share/keyrings/trivy.gpg
sudo rm -f /usr/share/keyrings/trivy.asc

wget -qO - \
    https://aquasecurity.github.io/trivy-repo/deb/public.key \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
    | sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null

sudo apt-get update -y

sudo apt-get install -y trivy

echo "Trivy version:"
trivy --version

