<h1>Atividade AWS – Docker</h1>

<h3>Objetivos:</h3>

- instalação e configuração do DOCKER ou CONTAINERD no host EC2;
Ponto adicional para o trabalho utilizar a instalação via script de Start Instance (user_data.sh)

- Efetuar Deploy de uma aplicação Wordpress com:
  * container de aplicação
  * RDS database Mysql

- configuração da utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress

- configuração do serviço de Load Balancer AWS para a aplicação Wordpress


<h3>A Pontos de Atenção:</h3>

- não utilizar ip público para saída do serviços WP (Evitem publicar o serviço WP via IP Público)
- sugestão para o tráfego de internet sair pelo LB (Load Balancer Classic)
- pastas públicas e estáticos do wordpress sugestão de uilizar o EFS (Elastic File Sistem)
- Fica a critério de cada integrante usar Dockerfile ou Dockercompose;
- Necessário demonstrar a aplicação wordpress funcionando (tela de login)
- Aplicação Wordpress precisa estar rodando na porta 80 ou 8080;
- Utilizar repositório gitpara versionamento;

<h3>Configuração da VPC</h3>

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
