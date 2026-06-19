#!/bin/bash

# Script de provisionamento para o DevOps Team Infrastructure Lab
# Este script configura usuários, grupos e a estrutura de diretórios com permissões.

# --- Variáveis de Configuração ---
PROJECT_BASE_DIR="/opt/dev_projects"
PROJECT_NAME="project_alpha"

# Senha padrão para todos os usuários (para fins de demonstração)
DEFAULT_PASSWORD="password123"

# --- Funções Auxiliares ---
log_action() {
    echo "[INFO] $1"
}

error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

# --- 2. Criação de Usuários e Atribuição a Grupos ---
log_action "Criando usuários e atribuindo a grupos..."

# Usuários: username, primary_group, secondary_groups (separados por vírgula)
USERS=(
    "dev1,developers,sudo"
    "dev2,developers,"
    "tester1,testers,"
    "pm1,project_managers,"
    "admin1,admins,sudo"
)

# --- 1. Criação de Grupos ---
log_action "Criando grupos..."
# Mudamos o nome de GROUPS para LISTA_GRUPOS para evitar conflito com a variável reservada do Linux
LISTA_GRUPOS=("developers" "testers" "project_managers" "admins")
for GRP in "${LISTA_GRUPOS[@]}"; do
    if ! getent group "$GRP" > /dev/null; then
        sudo groupadd "$GRP" || error_exit "Falha ao criar o grupo $GRP."
        log_action "Grupo '$GRP' criado."
    else
        log_action "Grupo '$GRP' já existe."
    fi
done

for USER_DATA in "${USERS[@]}"; do
    # Divide a string pelas vírgulas
    IFS=',' read -r USERNAME PRIMARY_GROUP SECONDARY_GROUPS <<< "$USER_DATA"

    # Remove quebras de linha ou espaços residuais da string de grupos secundários
    SECONDARY_GROUPS=$(echo "$SECONDARY_GROUPS" | tr -d '[:space:]')

    if ! id -u "$USERNAME" > /dev/null 2>&1; then
        log_action "Criando usuário '$USERNAME' com grupo primário '$PRIMARY_GROUP'."
        sudo useradd -m -g "$PRIMARY_GROUP" "$USERNAME" || error_exit "Falha ao criar o usuário $USERNAME."
        echo "$USERNAME:$DEFAULT_PASSWORD" | sudo chpasswd || error_exit "Falha ao definir senha para $USERNAME."

        # Validação segura: só roda o usermod se a variável não estiver vazia
        if [ -n "$SECONDARY_GROUPS" ]; then
            log_action "Adicionando usuário '$USERNAME' aos grupos secundários: $SECONDARY_GROUPS."
            sudo usermod -aG "$SECONDARY_GROUPS" "$USERNAME" || error_exit "Falha ao adicionar $USERNAME aos grupos secundários."
        fi
        log_action "Usuário '$USERNAME' criado e configurado."
    else
        log_action "Usuário '$USERNAME' já existe. Verificando grupos..."
        sudo usermod -g "$PRIMARY_GROUP" "$USERNAME" || error_exit "Falha ao definir grupo primário para $USERNAME."

        # Validação segura para usuários existentes
        if [ -n "$SECONDARY_GROUPS" ]; then
            sudo usermod -aG "$SECONDARY_GROUPS" "$USERNAME" || error_exit "Falha ao adicionar $USERNAME aos grupos secundários."
        fi
    fi
done

# --- 3. Criação da Estrutura de Diretórios ---
log_action "Criando estrutura de diretórios para projetos..."

sudo mkdir -p "$PROJECT_BASE_DIR" || error_exit "Falha ao criar $PROJECT_BASE_DIR."
sudo chown root:root "$PROJECT_BASE_DIR" || error_exit "Falha ao definir proprietário de $PROJECT_BASE_DIR."
sudo chmod 755 "$PROJECT_BASE_DIR" || error_exit "Falha ao definir permissões de $PROJECT_BASE_DIR."
log_action "Diretório base '$PROJECT_BASE_DIR' criado."

PROJECT_PATH="$PROJECT_BASE_DIR/$PROJECT_NAME"
sudo mkdir -p "$PROJECT_PATH" || error_exit "Falha ao criar $PROJECT_PATH."
# Definir SGID para o diretório do projeto para herdar o grupo 'developers'
sudo chown root:developers "$PROJECT_PATH" || error_exit "Falha ao definir proprietário/grupo de $PROJECT_PATH."
sudo chmod 2775 "$PROJECT_PATH" || error_exit "Falha ao definir permissões de $PROJECT_PATH."
log_action "Diretório do projeto '$PROJECT_PATH' criado com SGID."

# Subdiretórios e suas permissões específicas
SUBDIRS=("src,developers,2770" "tests,testers,2770" "docs,project_managers,2770" "builds,developers,2770")

for DIR_DATA in "${SUBDIRS[@]}"; do
    IFS=',' read -r DIR_NAME GROUP PERMS <<< "$DIR_DATA"
    CURRENT_DIR_PATH="$PROJECT_PATH/$DIR_NAME"
    sudo mkdir -p "$CURRENT_DIR_PATH" || error_exit "Falha ao criar $CURRENT_DIR_PATH."
    sudo chown root:"$GROUP" "$CURRENT_DIR_PATH" || error_exit "Falha ao definir proprietário/grupo de $CURRENT_DIR_PATH."
    sudo chmod "$PERMS" "$CURRENT_DIR_PATH" || error_exit "Falha ao definir permissões de $CURRENT_DIR_PATH."
    log_action "Subdiretório '$CURRENT_DIR_PATH' criado com grupo '$GROUP' e permissões '$PERMS'."
done

# --- 4. Configuração de Permissões Adicionais (ACLs - Access Control Lists) ---
log_action "Configurando ACLs para permissões granulares..."

# Instalar acl se não estiver presente
if ! dpkg -s acl > /dev/null 2>&1; then
    log_action "Pacote 'acl' não encontrado. Instalando..."
    sudo apt-get update && sudo apt-get install -y acl || error_exit "Falha ao instalar o pacote 'acl'."
fi

# src/: developers (rw), testers (r), pm1 (r)
sudo setfacl -m g:developers:rwx "$PROJECT_PATH/src" || error_exit "Falha ao configurar ACL para src/developers."
sudo setfacl -m g:testers:r-x "$PROJECT_PATH/src" || error_exit "Falha ao configurar ACL para src/testers."
sudo setfacl -m u:pm1:r-x "$PROJECT_PATH/src" || error_exit "Falha ao configurar ACL para src/pm1."

# tests/: testers (rwx), developers (r), pm1 (r)
sudo setfacl -m g:testers:rwx "$PROJECT_PATH/tests" || error_exit "Falha ao configurar ACL para tests/testers."
sudo setfacl -m g:developers:r-x "$PROJECT_PATH/tests" || error_exit "Falha ao configurar ACL para tests/developers."
sudo setfacl -m u:pm1:r-x "$PROJECT_PATH/tests" || error_exit "Falha ao configurar ACL para tests/pm1."

# docs/: project_managers (rwx), developers (r), testers (r)
sudo setfacl -m g:project_managers:rwx "$PROJECT_PATH/docs" || error_exit "Falha ao configurar ACL para docs/project_managers."
sudo setfacl -m g:developers:r-x "$PROJECT_PATH/docs" || error_exit "Falha ao configurar ACL para docs/developers."
sudo setfacl -m g:testers:r-x "$PROJECT_PATH/docs" || error_exit "Falha ao configurar ACL para docs/testers."

# builds/: developers (rwx), testers (r), pm1 (r)
sudo setfacl -m g:developers:rwx "$PROJECT_PATH/builds" || error_exit "Falha ao configurar ACL para builds/developers."
sudo setfacl -m g:testers:r-x "$PROJECT_PATH/builds" || error_exit "Falha ao configurar ACL para builds/testers."
sudo setfacl -m u:pm1:r-x "$PROJECT_PATH/builds" || error_exit "Falha ao configurar ACL para builds/pm1."

log_action "ACLs configuradas com sucesso."

log_action "Provisionamento do ambiente concluído com sucesso!"
log_action "Para testar, você pode fazer login como um dos usuários criados (e.g., 'su - dev1') e verificar as permissões."
log_action "Lembre-se que as senhas são '$DEFAULT_PASSWORD'."
