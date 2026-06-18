#!/bin/bash

# Script para auditoria de permissões em diretórios críticos do projeto

log_action() {
    echo "[INFO] $1"
}

error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

# --- Variáveis de Configuração ---
PROJECT_BASE_DIR="/opt/dev_projects"
PROJECT_NAME="project_alpha"
PROJECT_PATH="$PROJECT_BASE_DIR/$PROJECT_NAME"

# --- Funções de Auditoria ---
audit_directory_permissions() {
    local DIR_PATH=$1
    log_action "Auditando permissões para o diretório: $DIR_PATH"
    ls -ld "$DIR_PATH" || error_exit "Diretório $DIR_PATH não encontrado."
    getfacl "$DIR_PATH" || error_exit "Falha ao obter ACLs para $DIR_PATH."
}

# --- Execução da Auditoria ---
log_action "Iniciando auditoria de permissões para o projeto '$PROJECT_NAME'..."

if [ ! -d "$PROJECT_PATH" ]; then
    error_exit "O diretório do projeto '$PROJECT_PATH' não existe. Execute setup_env.sh primeiro."
fi

audit_directory_permissions "$PROJECT_PATH"
audit_directory_permissions "$PROJECT_PATH/src"
audit_directory_permissions "$PROJECT_PATH/tests"
audit_directory_permissions "$PROJECT_PATH/docs"
audit_directory_permissions "$PROJECT_PATH/builds"

log_action "Auditoria de permissões concluída."
log_action "Verifique a saída acima para garantir que as permissões e ACLs estão conforme o esperado."
