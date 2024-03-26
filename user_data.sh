#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
systemctl enable docker
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -sL "https://github.com/igormorantos/Aws-Docker/blob/main/dockerCompose.yaml" --output "/home/ec2-user/docker-compose.yaml"
yum install nfs-utils -y
mkdir /mnt/efs/
chmod +rwx /mnt/efs/
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0ad0232152702347b.efs.us-east-1.amazonaws.com:/ /mnt/efs/
echo "fs-0ad0232152702347b.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs defaults 0 0" >> /etc/fstab
usermod -aG docker ${USER}
chmod 666 /var/run/docker.sock
docker-compose -f /home/ec2-user/docker-compose.yaml up -d