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

