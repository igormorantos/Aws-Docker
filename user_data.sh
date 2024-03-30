#!/bin/bash

# Atualização do sistema
sudo yum update -y

# Instalação do Docker
sudo yum install docker -y

# Ativação do serviço Docker
sudo systemctl start docker
sudo systemctl enable docker

# Instalação do Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Criação do ponto de montagem EFS (opcional)
sudo mkdir /efs
sudo chmod +rwx /efs

sudo yum install amazon-efs-utils -y

sudo yum install python3-pip -y

sudo pip3 install botocore

# Montagem do EFS (opcional)
# Substitua "fs-0c2450fab7143e6e8.efs.us-east-1.amazonaws.com" pelo ID do seu EFS
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 172.29.0.120:/ /efs

# Download do arquivo docker-compose.yaml
sudo curl -o /home/ec2-user/dockerCompose.yaml "https://raw.githubusercontent.com/igormorantos/Aws-Docker/main/docker-compose.yaml"

# Adição do usuário ao grupo Docker
sudo usermod -aG docker ${USER}

# Permissão para o socket do Docker
sudo chmod 666 /var/run/docker.sock

# Execução do Docker Compose
sudo docker-compose -f /home/ec2-user/dockerCompose.yaml up -d
