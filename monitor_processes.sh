#!/bin/bash

# Script para monitorar processos de usuários específicos ou do sistema

log_action() {
    echo "[INFO] $1"
}

error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

# --- Funções de Monitoramento ---
monitor_user_processes() {
    local USERNAME=$1
    log_action "Monitorando processos do usuário: $USERNAME"
    ps -u "$USERNAME" -o pid,user,cmd,%cpu,%mem --sort=-%cpu | head -n 10
}

monitor_system_load() {
    log_action "Monitorando carga do sistema (top -bn1 | head -n 5)"
    top -bn1 | head -n 5
}

monitor_memory_usage() {
    log_action "Monitorando uso de memória (free -h)"
    free -h
}

monitor_disk_usage() {
    log_action "Monitorando uso de disco (df -h)"
    df -h
}

# --- Execução do Monitoramento ---
log_action "Iniciando monitoramento de processos e recursos do sistema..."

# Exemplo de monitoramento para usuários específicos
monitor_user_processes "dev1"
echo "\n"
monitor_user_processes "tester1"
echo "\n"

# Monitoramento geral do sistema
monitor_system_load
echo "\n"
monitor_memory_usage
echo "\n"
monitor_disk_usage

log_action "Monitoramento concluído."
