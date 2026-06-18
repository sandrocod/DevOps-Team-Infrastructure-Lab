# Plano de Arquitetura para o DevOps Team Infrastructure Lab

Este documento detalha a arquitetura da simulação de ambiente de desenvolvimento, incluindo a definição de usuários, grupos, estrutura de diretórios e políticas de permissão.

## 1. Definição de Usuários e Grupos

Serão criados os seguintes usuários e grupos para simular uma equipe de desenvolvimento:

### Grupos:

| Grupo              | Descrição                                         |
| :----------------- | :------------------------------------------------ |
| `developers`       | Membros da equipe de desenvolvimento.             |
| `testers`          | Membros da equipe de QA/Testes.                   |
| `project_managers` | Gerentes de projeto.                              |
| `admins`           | Administradores do sistema (para gestão da infra).|

### Usuários:

| Usuário    | Grupo Primário     | Grupos Secundários | Descrição                                    |
| :--------- | :----------------- | :----------------- | :------------------------------------------- |
| `dev1`     | `developers`       | `sudo`             | Desenvolvedor 1 (com acesso sudo para simular ambiente de dev) |
| `dev2`     | `developers`       | -                  | Desenvolvedor 2                              |
| `tester1`  | `testers`          | -                  | Testador 1                                   |
| `pm1`      | `project_managers` | -                  | Gerente de Projeto 1                         |
| `admin1`   | `admins`           | `sudo`             | Administrador do Sistema                     |

**Observação:** As senhas para todos os usuários serão definidas como `password123` para fins de demonstração.

## 2. Estrutura de Diretórios e Permissões

A estrutura de diretórios será criada sob `/opt/dev_projects/` para hospedar os projetos da equipe. Um projeto de exemplo, `project_alpha`, será configurado.

### Estrutura:

```
/opt/dev_projects/
└── project_alpha/
    ├── src/        # Código fonte do projeto
    ├── tests/      # Scripts de teste
    ├── docs/       # Documentação do projeto
    └── builds/     # Artefatos de build
```

### Políticas de Permissão para `project_alpha`:

| Diretório         | Proprietário | Grupo            | Permissões (Octal) | Descrição                                                                                             |
| :---------------- | :----------- | :--------------- | :----------------- | :---------------------------------------------------------------------------------------------------- |
| `/opt/dev_projects/` | `root`       | `root`           | `755`              | Base para todos os projetos. Apenas root pode criar novos projetos.                                   |
| `project_alpha/`  | `root`       | `developers`     | `2775`             | `sgid` para que novos arquivos herdem o grupo `developers`. `rwx` para proprietário e grupo, `rx` para outros. |
| `src/`            | `root`       | `developers`     | `2770`             | `sgid`. `developers` podem ler/escrever. `testers` podem ler. `pm1` pode ler.                         |
| `tests/`          | `root`       | `testers`        | `2770`             | `sgid`. `testers` podem ler/escrever. `developers` podem ler. `pm1` pode ler.                         |
| `docs/`           | `root`       | `project_managers` | `2770`             | `sgid`. `project_managers` podem ler/escrever. `developers` e `testers` podem ler.                    |
| `builds/`         | `root`       | `developers`     | `2770`             | `sgid`. `developers` podem ler/escrever. `testers` podem ler. `pm1` pode ler.                         |

**Explicação das Permissões:**

-   **`sgid` (Set Group ID - bit `2` no primeiro dígito):** Garante que qualquer arquivo ou diretório criado dentro de um diretório com `sgid` herde o grupo do diretório pai, em vez do grupo primário do usuário que o criou. Isso é crucial para a colaboração em equipe, mantendo a propriedade do grupo consistente.
-   **`770`**: `rwx` para proprietário, `rwx` para grupo, `---` para outros.
-   **`775`**: `rwx` para proprietário, `rwx` para grupo, `r-x` para outros.

## 3. Scripts de Automação (a serem desenvolvidos)

-   `setup_env.sh`: Script mestre para provisionar todos os usuários, grupos e a estrutura de diretórios com as permissões corretas.
-   `monitor_processes.sh`: Script para monitorar processos específicos de usuários ou grupos.
-   `audit_permissions.sh`: Script para verificar e reportar permissões de arquivos e diretórios críticos.

## 4. Tarefas e Fluxos de Trabalho (Exemplos)

-   **Desenvolvedor (`dev1`, `dev2`):** Acesso total a `src/` e `builds/`. Apenas leitura em `tests/` e `docs/`.
-   **Testador (`tester1`):** Acesso total a `tests/`. Apenas leitura em `src/`, `docs/` e `builds/`. Pode executar scripts de teste.
-   **Gerente de Projeto (`pm1`):** Acesso total a `docs/`. Apenas leitura em `src/`, `tests/` e `builds/`.
-   **Administrador (`admin1`):** Acesso total a toda a estrutura para manutenção e auditoria.

Este plano servirá como base para a implementação do ambiente simulado.
