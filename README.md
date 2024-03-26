<h1>Atividade AWS – Docker</h1>

<h3>Objetivos:</h3>

- instalação e configuração do DOCKER ou CONTAINERD no host EC2;
Ponto adicional para o trabalho utilizar a instalação via script de Start Instance (user_data.sh)

- Efetuar Deploy de uma aplicação Wordpress com:
  * container de aplicação
  * RDS database Mysql

- configuração da utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress

- configuração do serviço de Load Balancer AWS para a aplicação Wordpress

<h3>Arquitetura</h3>
![1](https://github.com/igormorantos/Aws-Docker/assets/94862012/28b3e75c-be2a-4826-9a4c-7e924adcb33f)


<h3>A Pontos de Atenção:</h3>

- não utilizar ip público para saída do serviços WP (Evitem publicar o serviço WP via IP Público)
- sugestão para o tráfego de internet sair pelo LB (Load Balancer Classic)
- pastas públicas e estáticos do wordpress sugestão de uilizar o EFS (Elastic File Sistem)
- Fica a critério de cada integrante usar Dockerfile ou Dockercompose;
- Necessário demonstrar a aplicação wordpress funcionando (tela de login)
- Aplicação Wordpress precisa estar rodando na porta 80 ou 8080;
- Utilizar repositório gitpara versionamento;

## Configuração da VPC

![1](https://github.com/igormorantos/Aws-Docker/assets/94862012/b98bcccd-e81e-4461-beef-669b1baa192d)

<h4>Configuração das sub-redes</h4>

utilizei a VPC `aws-docker`, usaremos 4 sub-redes, sendo 2 privadas, que contém a instância da aplicação, e a outra pública, que contém a instância do bastion em diferentes zonas de disponibilidades. Então, navegue para seção de sub-redes.

- Criando sub-redes privada
    - `Nome: aws-docker-private-subnet-wp`
    - `Zona de disponibilidade: us-east-1a`
    - `CIDR: 172.29.0.0/24`
   
    - `Nome: aws-docker-private-subnet-wp2`
    - `Zona de disponibilidade: us-east-1b`
    - `CIDR: 172.29.4.0/24`

- Criando sub-redes pública
    - `Nome: aws-docker-public-subnet-1a`
    - `Zona de disponibilidade: us-east-1a`
    - `CIDR: 172.29.2.0/24`

    - `Nome: aws-docker-public-subnet-1b`
    - `Zona de disponibilidade: us-east-1b`
    - `CIDR: 172.29.3.0/24`

<h4>Configuração dos Gateways</h4>

Para uma instância privada obter acesso a internet para baixar/instalar alguns pacotes devemos utilizar um gateway NAT, o qual é associado a um gateway da internet. Então, navegue para seção de gateway.

- Criando gateway da internet
    - `Nome: igateway-aws-docker`
    
- Criando gateway NAT
    - `Nome: gatewayNat-wp`
    - `Sub-rede: aws-docker-private-subnet-wp, aws-docker-private-subnet-wp2`
    - `Conectividade: Público`
    - `IP elástico: alocar IP elástico`

## Pares de Chave

é nescessario criar um par chaves para acessar as instancias EC2.
- Par de Chaves
    - `Nome: aws-docker.pem`
    - `Tipo: RSA`
    
## Criando instancias

<h5>Criando as instancias Ec2 host e de aplicação.</h5>

- Configuração das instancias host
    - `AMI: Linux 2`
    - `VPC: aws-docker`
    - `Par Chaves: aws-docker.pem`
    - `Tipo da instância: t2.micro`
    - `subnet: aws-docker-public-subnet-1a`

## Load Balancer

<h6>Como Solicitado nos pontos de atenção o load balancer criado é o classic.</h6>

 - Passo a passo de criação do load balancer classic:

 - ` Ir para a seção de load balancers na AWS`
 - ` Clicar em criar lod balancer`
 - ` Selecionar o tipo de "Classic Load Balancer`
 - ` Escolha o nome do load balancer`
 - ` Selecionar o esquema "Voltado para internet`
 - ` Selecionar a VPC`
 - ` Selecionar as subnets públicas de cada zona`
 - ` Selecionar grupo de segurança para o load balancer`

## EFS

Para criar o Elastic File System, basta:

 - `Ir em Criar sistema de arquivo`
 - `Criar nome do EFS`
 - `Escolher a vpc`
 - `Ir no FS criado`
 - `Visualizar detalhes`
 - `Ir em redes`
 - `escolher o grupode segurança determinado`

## RDS

O RDS foi configurado seguindo as etapas:

 - `Entrar em RDS.`
 - `Clicar em Criar Banco de dados`
 - `Selecionar de criação padrão`
 - `Selecionar o banco MySQL`
 - `Selecionar o modelo free tier`
 - `Solicitar Disponibilidade e durabilidade Cluster de banco de dados Multi-AZ`
 - `Escolher o nome do banco de dados`
 - `Escolher nome do usuário e senha`
 - `Escolher configuração de instância foi "db.m5d.large"`
 - `Em conectividade marcar opção "não se conectar a um recurso de computação do EC2"`
 - `Escolher a VPC criada anteriormente`
 - `Escolher grupo de sub-redes`
 - `Utilizar grupo de segurança criado para o RDS`
 - `Selecionar a zona de disponibilidade como "Sem preferência`
