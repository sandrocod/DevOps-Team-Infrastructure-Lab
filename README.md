# DevOps Team Infrastructure Lab

Este projeto simula um ambiente de infraestrutura de equipe de desenvolvimento (DevOps) em um sistema Linux, demonstrando habilidades avançadas em administração de sistemas, gerenciamento de usuários e grupos, controle de permissões granulares (incluindo ACLs), monitoramento de processos e automação via scripts Bash.

## Visão Geral do Projeto

O objetivo principal é criar um ambiente controlado onde diferentes papéis de equipe (Desenvolvedores, Testadores, Gerentes de Projeto, Administradores) têm acesso e permissões específicas a recursos de projeto. Você atuará como o administrador do sistema, provisionando a infraestrutura e garantindo a segurança e a colaboração.

Este laboratório é uma excelente forma de demonstrar para recrutadores sua proficiência em:

-   **Gerenciamento de Usuários e Grupos**: Criação e atribuição de usuários a grupos primários e secundários.
-   **Gerenciamento de Permissões**: Uso de `chmod`, `chown`, `chgrp` e, crucialmente, **ACLs (Access Control Lists)** para controle de acesso granular.
-   **Estrutura de Diretórios Segura**: Organização de projetos com herança de permissões (`sgid`).
-   **Automação com Scripts Bash**: Provisionamento de ambiente e tarefas de monitoramento/auditoria.
-   **Monitoramento de Processos**: Identificação e gestão de processos em execução.
-   **Auditoria de Segurança**: Verificação da conformidade das permissões.

## Arquitetura da Simulação

Para detalhes completos sobre a definição de usuários, grupos, estrutura de diretórios e políticas de permissão, consulte o arquivo [`devops_architecture_plan.md`](devops_architecture_plan.md).

Em resumo, a arquitetura inclui:

-   **Grupos**: `developers`, `testers`, `project_managers`, `admins`.
-   **Usuários**: `dev1`, `dev2`, `tester1`, `pm1`, `admin1` (com senhas padrão `password123`).
-   **Estrutura de Diretórios**: `/opt/dev_projects/project_alpha/` com subdiretórios `src/`, `tests/`, `docs/`, `builds/`.
-   **Permissões**: Configurações `chmod` tradicionais e ACLs para garantir que cada usuário tenha o nível de acesso apropriado a cada parte do projeto.

## Estrutura do Repositório

```
DevOps-Team-Infrastructure-Lab/
├── setup_env.sh              # Script mestre para provisionar o ambiente
├── monitor_processes.sh      # Script para monitorar processos de usuários
├── audit_permissions.sh      # Script para auditar permissões de diretórios
├── devops_architecture_plan.md # Documento detalhado da arquitetura
├── README.md                 # Este arquivo
└── PRESENTATION_GUIDE.md     # Guia para apresentar o projeto a recrutadores
```

## Como Usar

### 1. Clonar o Repositório

```bash
git clone https://github.com/sandrocod/DevOps-Team-Infrastructure-Lab.git
cd DevOps-Team-Infrastructure-Lab
```

### 2. Provisionar o Ambiente

Execute o script `setup_env.sh` com privilégios de superusuário. Este script criará os grupos, usuários, estrutura de diretórios e configurará as permissões e ACLs. Ele também instalará o pacote `acl` se necessário.

```bash
sudo ./setup_env.sh
```

### 3. Testar o Ambiente

Após o provisionamento, você pode testar as permissões e o acesso fazendo login como os usuários criados. Por exemplo:

```bash
su - dev1
pwd
ls -l /opt/dev_projects/project_alpha/src
# Tente criar um arquivo em src/ (deve funcionar)
touch /opt/dev_projects/project_alpha/src/new_dev_file.txt
exit # Para sair do usuário dev1

su - tester1
pwd
ls -l /opt/dev_projects/project_alpha/tests
# Tente criar um arquivo em tests/ (deve funcionar)
touch /opt/dev_projects/project_alpha/tests/new_test_file.txt
# Tente criar um arquivo em src/ (NÃO deve funcionar)
touch /opt/dev_projects/project_alpha/src/forbidden_file.txt
exit
```

### 4. Executar Scripts de Monitoramento e Auditoria

Como `admin1` ou `root`, você pode executar os scripts de monitoramento e auditoria:

```bash
sudo ./monitor_processes.sh
sudo ./audit_permissions.sh
```

## Limpeza do Ambiente

Para remover os usuários, grupos e diretórios criados por este laboratório, você pode usar o script `cleanup_env.sh` (não fornecido, mas pode ser criado como um exercício adicional). Alternativamente, remova manualmente:

```bash
sudo rm -rf /opt/dev_projects
sudo userdel -r dev1 dev2 tester1 pm1 admin1
sudo groupdel developers testers project_managers admins
```

## Contribuição

Sinta-se à vontade para fazer um fork deste repositório, propor melhorias ou adicionar novas funcionalidades. Suas contribuições são bem-vindas!

## Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo `LICENSE` para mais detalhes.
