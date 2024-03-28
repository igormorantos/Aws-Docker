#!/bin/bash
# Responsável por atualizar o sistema
sudo yum update -y
# Instalar o docker
sudo yum install docker -y
# Inicializar o docker
sudo systemctl start docker
# Habilitar o docker juntamente do início da instância
sudo systemctl enable docker
# Dar um curl no docker-compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# Dar permissões necessárias
sudo chmod +x /usr/local/bin/docker-compose
# Dar um curl no arquivo .yaml do meu git-hub e criar um arquivo de mesmo nome contendo seu conteúdo
sudo curl -o dockerCompose.yaml "https://raw.githubusercontent.com/igormorantos/Aws-Docker/main/dockerCompose.yaml"
# Instalar cliente nfs 
sudo sudo yum install -y amazon-efs-utils
# Criar diretório para montagem
sudo mkdir /efs
# Dar permissões necessárias ao diretório ( leitura, escrita e execução ) 
sudo chmod +rwx /efs
# Montar o sistema de arquivos com o EFS
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0647fdec6707f2113.efs.us-east-1.amazonaws.com:/ /mnt/efs/
# Habilitar montagem automatica quando a máquina inicializar
echo "fs-07c68e847f4ea9744.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs defaults 0 0" >> /etc/fstab
# Adicionar o usuário atual no grupo do docker
usermod -aG docker ${USER}
# Dar permissão de leitura e escrita no docker.sock
chmod 666 /var/run/docker.sock
# Criar o container com docker-compose utilizando a imagem do .yaml
docker-compose -f /home/ec2-user/docker-compose.yaml up -d