#!/bin/bash
echo ">>> Runs on the host: $(hostnamectl |grep hostname)"
echo ''
echo '------------------------------------------'
echo '>>> Install base packages'
yum -y install wget vim emacs net-tools
echo ''

echo '>>> Checking path of installed packages'
echo "  wget: $(which wget)"
echo "  vim: $(which vim)"
echo "  emacs: $(which emacs)"
echo "  ifconfig: $(which ifconfig)"
echo ''

echo '>>> Install kubectl from source'
curl -s -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
echo ''

# Case if installing with yum repository
# echo '>>> Enable yum repository for kubernetes'
# cat << EOF > /etc/yum.repos.d/kubernetes.repo
# [kubernetes]
# name=Kubernetes
# baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
# enabled=1
# gpgcheck=1
# repo_gpgcheck=1
# gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
# EOF
#
# echo ''
#
# echo '>>> Checking yum repository configs before downloading ...'
# ls -al /etc/yum.repos.d/
# echo ''
# cat /etc/yum.repos.d/kubernetes.repo
# echo ''
# yum -y repolist
# echo ''
# echo 'Downloading kubectl'
# yum -y install kubectl
# echo ''

echo '>>> Post installation of kubectl'
ls -al ./kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
echo ''
echo '>>> Check path and versions'
which kubectl
kubectl version
echo ''

echo '>>> Create users and setup'
for i in {01..04}; do
    echo ">>>>>> Create user${i} with home directory"
    echo ''
    useradd "user${i}" -g wheel
    ls -al "/home/user${i}"
    echo "Setting up password"
    echo 'VMware1!' |passwd --stdin "user${i}"
    echo ''
    mkdir -p "/home/user${i}/.kube"
    ls -al "/home/user${i}/.kube"
    echo ''
done

echo '>>> Check users exists'
cat /etc/passwd |grep -E "user.[0-9]"

echo '>>> All done!'

