#!/bin/bash

#Faça um script com menu interativo que aplica perfis 
#de permissão em todos os arquivos e diretórios de 
#um caminho escolhido pelo usuário. 
#O script deve: – Apresentar menu com perfis: somente leitura, 
#leitura e escrita, restrito, executável – 
#Aplicar permissões diferentes para arquivos e 
#para diretórios dentro do caminho – Exibir resumo de quantos 
#arquivos e diretórios foram alterados – 
#Pedir confirmação antes de aplicar e registrar as alterações em log

# ==========================================
# Script: gerenciar_permissoes.sh
# Descrição:
# Aplica perfis de permissões em arquivos
# e diretórios de forma interativa.
# ==========================================

# Cores
RED=$'\033[0;31m';  GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; RED_BOLD=$'\033[1;31m'; GREEN_BOLD=$'\033[1;32m';
CYAN=$'\033[0;36m'; BOLD=$'\033[1m';     RESET=$'\033[0m';     BOLD=$'\033[1m'

LOG_FILE="alteracoes_permissoes.log"

echo "${CYAN}"
echo "████  █████ ████  █   █ ███  ████  ████ ███  ███  █   █    █   █  ███  █   █  ███   ███  █████ ████    "
echo "█░░░█ █░░░░░█░░░█ ██ ██░ █░░█ ░░░░█ ░░░░ █░░█ ░░█ ██  █░   ██ ██░█ ░░█ ██  █░█ ░░█ █ ░░░ █░░░░░█░░░█   "
echo "████░░████░░████░░█░█ █░░█░░░███░░░███░░░█░░█░ ░█░█░█ █░░  █░█ █░█████░█░█ █░█████░█░ ██░████░░████░░  "
echo "█░░░░ █░░░░ █░░█░ █░░░█░░█░░  ░░█   ░░█  █░░█░░ █░█░░██░░  █░░░█░█░░░█░█░░██░█░░░█░█░░ █░█░░░░ █░░█░ ░ "
echo "█░░░░░█████░█░░░█░█░░ █░███░████░░████░░███░ ███ ░█░░ █░░  █░░ █░█░░░█░█░░ █░█░░░█░░███ ░█████░█░░░█░  "
echo " ░░    ░░░░░ ░░  ░ ░░  ░░░░░ ░░░░ ░░░░░ ░░░░  ░░░ ░░░  ░░   ░░  ░░░░  ░░░░  ░░░░  ░░ ░░░ ░░░░░░ ░░  ░  "
echo "  ░     ░░░░░ ░   ░ ░   ░ ░░░ ░░░░  ░░░░  ░░░  ░░░  ░   ░    ░   ░ ░   ░ ░   ░ ░   ░  ░░░  ░░░░░ ░   ░ "
echo "${RESET}"

recebe_caminho (){
    while true; do
        read -rp "${BOLD}Digite o caminho do diretório: ${RESET}" CAMINHO

        # Expande variáveis como $HOME, $PWD, etc
        CAMINHO=$(bash -c "printf '%s' \"$CAMINHO\"")

        # Converte para caminho absoluto se necessário
        CAMINHO=$(realpath "$CAMINHO")

        if [[ -d "$CAMINHO" ]]; then
            break
        fi

        printf "%b\n" "${RED_BOLD}[ERRO]${RESET}${BOLD}: Diretório inválido, tente novamente.${RESET}"
    done
}

recebe_caminho

options(){
    echo
    echo -e "${YELLOW}${BOLD}Perfis disponíveis:${RESET}"
    echo
    echo -e "${GREEN}[1]${RESET} Somente leitura"
    echo -e "${GREEN}[2]${RESET} Leitura e escrita"
    echo -e "${GREEN}[3]${RESET} Restrito"
    echo -e "${GREEN}[4]${RESET} Executável"
    echo
    echo -e "${CYAN}[9]${RESET} Alterar diretório"
    echo -e "${RED}[0]${RESET} Sair"

    read -rp "${BOLD}Opção:${RESET} " OPCAO

    # Define permissões
    case $OPCAO in
        1)
            PERFIL="Somente leitura"
            PERM_ARQ="444"
            PERM_DIR="555"
            ;;
        2)
            PERFIL="Leitura e escrita"
            PERM_ARQ="664"
            PERM_DIR="775"
            ;;
        3)
            PERFIL="Restrito"
            PERM_ARQ="600"
            PERM_DIR="700"
            ;;
        4)
            PERFIL="Executável"
            PERM_ARQ="755"
            PERM_DIR="755"
            ;;
        9)
            recebe_caminho
            options
            ;;
        0)
            echo
            echo "${BOLD}Saindo...${RESET}"
            exit 1
            ;;
        *)
            echo "Opção inválida."
            exit 1
            ;;
    esac
}

options

TOTAL_ARQ=$(find "$CAMINHO" -type f | wc -l)
TOTAL_DIR=$(find "$CAMINHO" -type d | wc -l)

echo
echo "${CYAN}${BOLD}===============================================${RESET}"
echo "${CYAN}${BOLD}              RESUMO DA OPERAÇÃO              ${RESET}"
echo "${CYAN}${BOLD}===============================================${RESET}"
echo

echo "${BOLD}Perfil                  :${RESET}   $PERFIL"
echo "${BOLD}Diretório               :${RESET}   $CAMINHO"

echo

echo "${BOLD}Permissão de arquivos   ${RESET}:   $PERM_ARQ"
echo "${BOLD}Permissão de diretórios ${RESET}:   $PERM_DIR"
echo "${GREEN_BOLD}Diretórios encontrados  ${RESET}:   $TOTAL_DIR"
echo "${GREEN_BOLD}Arquivos encontrados    ${RESET}:   $TOTAL_ARQ"

echo
echo "${CYAN}${BOLD}===============================================${RESET}"

read -rp "${BOLD}Deseja continuar? (${GREEN_BOLD}s${RESET}/${RED_BOLD}n${RESET}): " CONFIRMA

if [[ "$CONFIRMA" != "s" && "$CONFIRMA" != "S" ]]; then
    options
fi

echo
echo "${BOLD}Aplicando permissões...${RESET}"

# Aplicação das permissões
find "$CAMINHO" -type f -exec chmod "$PERM_ARQ" {} \;
find "$CAMINHO" -type d -exec chmod "$PERM_DIR" {} \;

# Registro em log
{
    echo "[ INFORMAÇÃO ]"
    echo "Timestamp...........: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Usuário.............: $(whoami)"
    echo "Diretório alvo......: $CAMINHO"

    echo

    echo "[ CONFIGURAÇÃO ]"
    echo "Perfil..............: $PERFIL"
    echo "Permissão arquivos..: $PERM_ARQ"
    echo "Permissão diretórios: $PERM_DIR"

    echo

    echo "[ RESULTADO ]"
    echo "Arquivos alterados..: $TOTAL_ARQ"
    echo "Diretórios alterados: $TOTAL_DIR"

    echo "=================================================="
    echo

} >> "$LOG_FILE"

echo
echo "${GREEN_BOLD}==================================================${RESET}"
echo "${GREEN_BOLD}             OPERAÇÃO CONCLUÍDA                  ${RESET}"
echo "${GREEN_BOLD}==================================================${RESET}"
echo
echo "${BOLD}Diretório alvo        :${RESET} $CAMINHO"
echo "${BOLD}Perfil aplicado       :${RESET} $PERFIL"
echo
echo "${GREEN}Arquivos alterados   :${RESET} $TOTAL_ARQ"
echo "${GREEN}Diretórios alterados :${RESET} $TOTAL_DIR"
echo
echo "${CYAN}Log salvo em          :${RESET} $LOG_FILE"
echo
echo "${GREEN_BOLD}==================================================${RESET}"