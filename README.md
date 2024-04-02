# Atividade AWS – Docker

## Objetivos:

- instalação e configuração do DOCKER ou CONTAINERD no host EC2;
Ponto adicional para o trabalho utilizar a instalação via script de Start Instance (user_data.sh)

- Efetuar Deploy de uma aplicação Wordpress com:
  * container de aplicação
  * RDS database Mysql

- configuração da utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress

- configuração do serviço de Load Balancer AWS para a aplicação Wordpress

## Arquitetura:
![1](https://github.com/igormorantos/Aws-Docker/assets/94862012/28b3e75c-be2a-4826-9a4c-7e924adcb33f)


## A Pontos de Atenção:

- não utilizar ip público para saída do serviços WP (Evitem publicar o serviço WP via IP Público)
- sugestão para o tráfego de internet sair pelo LB (Load Balancer Classic)
- pastas públicas e estáticos do wordpress sugestão de uilizar o EFS (Elastic File Sistem)
- Fica a critério de cada integrante usar Dockerfile ou Dockercompose;
- Necessário demonstrar a aplicação wordpress funcionando (tela de login)
- Aplicação Wordpress precisa estar rodando na porta 80 ou 8080;
- Utilizar repositório gitpara versionamento;

## Configuração da VPC

![1](https://github.com/igormorantos/Aws-Docker/assets/94862012/82c6220f-5233-4559-8390-1b419efe8470)


<h4>Configuração das sub-redes</h4>

utilizei a VPC `aws-docker`, usaremos 2 sub-redes, que contém a instância da aplicação em diferentes zonas de disponibilidades. que são:

- Criando sub-redes públicas
    - `Nome: aws-docker-1a`
    - `Zona de disponibilidade: us-east-1a`
    - `CIDR: 172.29.2.0/24`

    - `Nome: aws-docker-1b`
    - `Zona de disponibilidade: us-east-1b`
    - `CIDR: 172.29.3.0/24`

## Tabela de rotas

Criei uma tabela de roteamento, sendo ela para as duas sub-redes, onde vai permitir o tráfego à internet pelo gateway da internet.

Criando a tabela de roteamento para sub-rede pública
Nome: `rtb-aws-docker-public`
VPC: `aws-docker`

Após isso devemos associar as sub-redes criadas anteriormente a tabela de roteamento.


## Associando as sub-redes pública a sua tabela de roteamento

Selecione a tabela de roteamento, siga para associações de sub-redes e selecione Editar associações. Após isso, selecione a sub-rede pública, com nome: `aws-docker-1a` e clique salvar.

Faça o mesmo para a `aws-docker-1b`

Além disso, devemos também permitir o tráfego a internet para cada sub-rede, sendo pelo gateway da internet para sub-rede pública.

## Configuração dos Gateways

Para uma instância publica obter acesso a internet para baixar e instalar alguns pacotes devemos utilizar um gateway da internet, va até gateway internet para realizar a criação.

Adicionando rota para gateway da internet na tabela de roteamento da sub-rede pública

Selecione a tabela de roteamento, siga para rotas e selecione Editar rotas. Após isso, selecione adicionar rotas e preencha:
  
- Criando gateway da internet
    - `Nome: igateway-aws-docker`
    - `Alvo: 0.0.0.0/0`

## Pares de Chave

é nescessario criar um par chaves para acessar as instancias EC2.
- Par de Chaves
    - `Nome: aws-docker.pem`
    - `Tipo: RSA`
    
## Criando instancias

## Configuração do grupo de segurança

Configurar 2 grupos de segurança, um para a instância e outro para o load balancer.

- Grupo de segurança do balanceador de carga
  Porta | Protocolo | Origem
  --- | --- | ---
  80  | TCP | 0.0.0.0/0

- Grupo de segurança da aplicação
  Porta | Protocolo | Origem 
  --- | --- | ---
  22 | TCP | "Seu Ip"
  2049 | TCP | Grupo de Segurança do efs
  80 | TCP | Grupo de segurança do balanceador de carga

<h5>Criando as instancias Ec2 host e de aplicação.</h5>

- Configuração das instancias host zona de disponibilidade 1a
    - `AMI: Linux 2`
    - `VPC: aws-docker`
    - `Par Chaves: aws-docker.pem`
    - `Tipo da instância: t2.micro`
    - `subnet: aws-docker-1a`

- Configuração das instancias host zona de disponibilidade 1b
    - `AMI: Linux 2`
    - `VPC: aws-docker`
    - `Par Chaves: aws-docker.pem`
    - `Tipo da instância: t2.micro`
    - `subnet: aws-docker-1b`

## Instalação Docker na instância

Para fazer as instalações do docker/docker-compose/efs/container-wordpress

```#!/bin/bash
#!/bin/bash

# Variáveis
EFS_VOLUME="/mnt/efs"
WORDPRESS_VOLUME="/var/www/html"
DATABASE_HOST="aws-docker1.c7i4k6wwgmzc.us-east-1.rds.amazonaws.com"
DATABASE_USER="admin"
DATABASE_PASSWORD="admin123"
DATABASE_NAME="aws_docker"

# Atualização do sistema
sudo yum update -y

# Instalação do Docker e do utilitário EFS
sudo yum install docker -y
sudo yum install amazon-efs-utils -y

# Adição do usuário ao grupo Docker
sudo usermod -aG docker $(whoami)

# Inicialização e ativação do serviço Docker
sudo systemctl start docker
sudo systemctl enable docker

# Criação do ponto de montagem EFS
sudo mkdir -p $EFS_VOLUME

# Montagem do volume EFS
if ! mountpoint -q $EFS_VOLUME; then
  echo "Montando volume EFS..."
  sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 10.1.3.178:/ $EFS_VOLUME
else
  echo "Volume EFS já montado."
fi

# Download do Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /bin/docker-compose
chmod +x /bin/docker-compose

# Criação do arquivo docker-compose.yaml
cat <<EOL > /home/ec2-user/docker-compose.yaml
version: '3.8'
services:
  wordpress:
    image: wordpress:latest
    volumes:
      - $EFS_VOLUME$WORDPRESS_VOLUME:/$WORDPRESS_VOLUME
    ports:
      - 80:80
    environment:
      WORDPRESS_DB_HOST: $DATABASE_HOST
      WORDPRESS_DB_USER: $DATABASE_USER
      WORDPRESS_DB_PASSWORD: $DATABASE_PASSWORD
      WORDPRESS_DB_NAME: $DATABASE_NAME
EOL

# Inicialização do serviço WordPress
docker-compose -f /home/ec2-user/docker-compose.yaml up -d
```

## Load Balancer

<h6>Passo a passo de criação do load balancer </h6>

 - ` Ir para a seção de load balancers na AWS`
 - ` Clicar em criar lod balancer`
 - ` Selecionar o tipo de "Application Load Balancer"`
 - ` Escolha o nome do load balancer "aws-docker-lb"`
 - ` Selecionar o esquema "Voltado para internet`
 - ` Selecionar a VPC "aws-docker"`
 - ` Selecionar as subnets públicas de cada zona`
 - ` Selecionar grupo de segurança para o load balancer`

    - `Nome: aws-docker-lb`
    - `Esquema: voltado pra internet`
    - `Tipo de endereço IP: IPv4`
    - `VPC: aws-docker`
    - `Grupo de segurança: "Load_balancer_SG"`

## EFS

Criando o Elastic File System:

 - `Ir em Criar sistema de arquivo`
 - `Criar nome do EFS: "efs-aws-docker"`
 - `Escolher a vpc: "aws-docker"`

## RDS

O RDS foi configurado seguindo as etapas:

 - `Entrar em RDS.`
 - `Clicar em Criar Banco de dados`
 - `Selecionar de criação padrão`
 - `Selecionar o banco MySQL`
 - `Selecionar o modelo nível gratuito`
 - `Escolher o nome do banco de dados`
 - `Escolher nome do usuário e senha`
 - `Escolher configuração de instância foi "db.t3.micro"`
 - `Em conectividade marcar opção "não se conectar a um recurso de computação do EC2"`
 - `Escolher a VPC: aws-docker`
 - `Escolher grupo de sub-redes`
 - `Utilizar grupo de segurança criado para o RDS`
 - `Selecionar a zona de disponibilidade como "Sem preferência`

