#!/bin/bash

echo ">>>>>>> Starting Docker installation."
echo "-----------------------------------------------------------------"
echo ""
echo ">>> Erase old packages and install dependencies"
yum -y remove docker docker-common docker-selinux docker-engine
yum -y install yum-utils device-mapper-persistent-data lvm2

echo "-----------------------------------------------------------------"
echo ""
echo ">>> Adding repository for docker installation"
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
echo "Available repositories"
yum repolist |grep -i docker

echo ">>> Optimizting yum configurations"
echo "This might take some times..."
yum makecache fast

echo "-----------------------------------------------------------------"
echo ""
echo ">>> Starting installation"
yum -y install docker-ce

echo ">>> Avaliable docker CE versions: "
yum list docker-ce.x86_64  --showduplicates | sort -r
docker version

echo "-----------------------------------------------------------------"
echo ""
echo ">>> Post configuration: Starting services"
systemctl status docker
systemctl start docker ; systemctl enable docker
chkconfig docker

echo ">>> Post configuration: Docker image test"
docker run hello-world

echo ">>> Post configuration: Post-Check scripts"
curl https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh > check-config.sh
chmod 744 check-config.sh
bash ./check-config.sh

echo "-----------------------------------------------------------------"
echo ""
echo ">>>>>>> Docker installation done."
exit 0
