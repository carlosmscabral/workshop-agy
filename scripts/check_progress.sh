#!/usr/bin/env bash
#
# Check Progress Script for Due Diligence Agent Workshop (workshop-agy)
# Validates local environment, Antigravity CLI, ADK agent setup, and deployment status.
#

set -uo pipefail

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

pass_count=0
fail_count=0
warn_count=0

function print_header() {
    echo -e "${CYAN}${BOLD}================================================================${NC}"
    echo -e "${CYAN}${BOLD}   Workshop-AGY: Verificador de Progresso do Aluno            ${NC}"
    echo -e "${CYAN}${BOLD}================================================================${NC}"
    echo ""
}

function check_pass() {
    local msg="$1"
    echo -e "  [ ${GREEN}PASS${NC} ] ${msg}"
    ((pass_count++))
}

function check_fail() {
    local msg="$1"
    local hint="${2:-}"
    echo -e "  [ ${RED}FAIL${NC} ] ${msg}"
    if [ -n "${hint}" ]; then
        echo -e "         ${YELLOW}↳ Dica: ${hint}${NC}"
    fi
    ((fail_count++))
}

function check_info() {
    local msg="$1"
    echo -e "  [ ${BLUE}INFO${NC} ] ${msg}"
}

function check_warn() {
    local msg="$1"
    local hint="${2:-}"
    echo -e "  [ ${YELLOW}WARN${NC} ] ${msg}"
    if [ -n "${hint}" ]; then
        echo -e "         ${YELLOW}↳ Dica: ${hint}${NC}"
    fi
    ((warn_count++))
}

function check_task_1() {
    echo -e "${BOLD}--- Validando Tarefa 1: Configuração do Ambiente e Antigravity CLI ---${NC}"

    # 1. Variáveis de ambiente
    local proj="${PROJECT_ID:-${DEVSHELL_PROJECT_ID:-}}"
    if [ -n "${proj}" ]; then
        check_pass "Variável PROJECT_ID configurada: ${proj}"
    else
        check_fail "PROJECT_ID não definido." "Execute: export PROJECT_ID=\$DEVSHELL_PROJECT_ID"
    fi

    local reg="${REGION:-}"
    if [ -n "${reg}" ]; then
        check_pass "Variável REGION configurada: ${reg}"
    else
        check_fail "REGION não definida." "Execute o bloco de descoberta de região da Tarefa 1."
    fi

    # 2. Utilitários uv e agy no PATH
    if command -v uv >/dev/null 2>&1; then
        local uv_ver=$(uv --version 2>/dev/null || echo "instalado")
        check_pass "Gerenciador uv detectado (${uv_ver})"
    else
        check_fail "uv não encontrado no PATH." "Execute: curl -LsSf https://astral.sh/uv/install.sh | sh"
    fi

    if command -v agy >/dev/null 2>&1; then
        check_pass "Antigravity CLI (agy) detectado no PATH."
    else
        check_fail "agy não encontrado no PATH." "Execute: curl -fsSL https://antigravity.google/cli/install.sh | bash"
    fi

    # 3. Autenticação agy
    if [ -d "${HOME}/.gemini" ] || [ -d "${HOME}/.antigravity" ]; then
        check_pass "Diretório de configuração do assistente agy inicializado."
    else
        check_warn "Configuração do agy não localizada em ~/.gemini." "Inicie o assistente digitando 'agy' no terminal e conclua a autenticação."
    fi
    echo ""
}

function check_task_2() {
    echo -e "${BOLD}--- Validando Tarefa 2: Instalação de Skills e Criação do Agente ---${NC}"

    # 1. Arquivo .env
    local env_file=".env"
    if [ -f "${env_file}" ] || [ -f "../${env_file}" ]; then
        check_pass "Arquivo de configuração .env localizado."
    else
        check_fail "Arquivo .env ausente." "Crie o arquivo .env com GOOGLE_CLOUD_PROJECT e GOOGLE_CLOUD_LOCATION conforme Tarefa 2."
    fi

    # 2. Skill de Due Diligence
    if [ -f "skills/due-diligence-contract/SKILL.md" ] || [ -f "../skills/due-diligence-contract/SKILL.md" ]; then
        check_pass "Skill de Due Diligence (SKILL.md) localizada no repositório."
    else
        check_fail "Skill de Due Diligence não encontrada." "Verifique se está no diretório correto: cd ~/workshop-agy"
    fi

    # 3. Contrato de teste
    if [ -f "docs/sample_contract.pdf" ] || [ -f "../docs/sample_contract.pdf" ]; then
        check_pass "Contrato de amostra (docs/sample_contract.pdf) disponível para testes."
    else
        check_fail "Contrato de amostra ausente em docs/sample_contract.pdf."
    fi

    # 4. Estrutura do agente criado
    local agent_dir=""
    if [ -d "due-diligence-agent" ]; then
        agent_dir="due-diligence-agent"
    elif [ -d "../due-diligence-agent" ]; then
        agent_dir="../due-diligence-agent"
    fi

    if [ -n "${agent_dir}" ]; then
        check_pass "Diretório do agente '${agent_dir}' detectado."
        if [ -f "${agent_dir}/pyproject.toml" ] || [ -f "${agent_dir}/agent.py" ]; then
            check_pass "Arquivos de código do agente localizados em '${agent_dir}'."
        else
            check_warn "Estrutura do agente em '${agent_dir}' parece incompleta." "Peça ao agy para gerar o agente ADK."
        fi
    else
        check_warn "Diretório 'due-diligence-agent' ainda não criado." "No agy, execute /grill-me e solicite a criação do agente com ADK."
    fi
    echo ""
}

function check_task_3() {
    echo -e "${BOLD}--- Validando Tarefa 3: Testes Locais com ADK Web ---${NC}"

    # Checar se a porta 8000 ou 8080 está ativa
    if command -v ss >/dev/null 2>&1 && ss -tulpn 2>/dev/null | grep -qE ":(8000|8080)\b"; then
        check_pass "Servidor ADK Web detectado respondendo na porta local."
    elif command -v netstat >/dev/null 2>&1 && netstat -tulpn 2>/dev/null | grep -qE ":(8000|8080)\b"; then
        check_pass "Servidor ADK Web detectado respondendo na porta local."
    else
        check_info "Servidor ADK Web não detectado em execução no momento (normal se os testes já foram finalizados com CTRL+C)."
    fi

    # Checar se o plugin de cota 429 está disponível
    if [ -f "workshop_utils/plugins.py" ] || [ -f "../workshop_utils/plugins.py" ]; then
        check_pass "Plugin de resiliência a quotas (Graceful429Plugin) disponível para o agente."
    fi
    echo ""
}

function check_task_4() {
    echo -e "${BOLD}--- Validando Tarefa 4: Implantação no Google Cloud Agent Runtime ---${NC}"

    local proj="${PROJECT_ID:-${DEVSHELL_PROJECT_ID:-}}"
    local reg="${REGION:-us-central1}"

    if [ -n "${proj}" ]; then
        check_info "Consultando serviços do Agent Runtime no projeto ${proj}..."
        if command -v gcloud >/dev/null 2>&1; then
            local services_enabled=$(gcloud services list --enabled --filter="name:(aiplatform.googleapis.com OR discoveryengine.googleapis.com)" --format="value(name)" 2>/dev/null || true)
            if echo "${services_enabled}" | grep -q "aiplatform.googleapis.com"; then
                check_pass "API Vertex AI (aiplatform.googleapis.com) ativa no projeto."
            else
                check_fail "API Vertex AI não está habilitada." "Execute: gcloud services enable aiplatform.googleapis.com"
            fi
            if echo "${services_enabled}" | grep -q "discoveryengine.googleapis.com"; then
                check_pass "API Discovery Engine / Agent Builder ativa no projeto."
            else
                check_fail "API Discovery Engine não está habilitada." "Execute: gcloud services enable discoveryengine.googleapis.com"
            fi
        fi
    fi
    echo ""
}

function check_task_5() {
    echo -e "${BOLD}--- Validando Tarefa 5: Publicação no Gemini Enterprise App ---${NC}"
    check_info "A publicação final no Gemini Enterprise App é realizada via Console do Google Cloud."
    check_info "Certifique-se de que:"
    echo -e "     1. A funcionalidade de Agentes (Agents) foi ativada na aba Features do App;"
    echo -e "     2. O Resource Name do agente foi colado no formato:"
    echo -e "        projects/<PROJECT_ID>/locations/<REGION>/agents/<AGENT_ID>"
    echo ""
}

# Main Execution
print_header

TARGET_TASK="${1:-all}"

case "${TARGET_TASK}" in
    1|--task-1|-1)
        check_task_1
        ;;
    2|--task-2|-2)
        check_task_2
        ;;
    3|--task-3|-3)
        check_task_3
        ;;
    4|--task-4|-4)
        check_task_4
        ;;
    5|--task-5|-5)
        check_task_5
        ;;
    all|*)
        check_task_1
        check_task_2
        check_task_3
        check_task_4
        check_task_5
        ;;
esac

echo -e "${CYAN}${BOLD}================================================================${NC}"
echo -e "${BOLD}Resumo da Verificação:${NC} ${GREEN}${pass_count} Passou${NC} | ${RED}${fail_count} Falhou${NC} | ${YELLOW}${warn_count} Alertas${NC}"
if [ ${fail_count} -eq 0 ]; then
    echo -e "${GREEN}${BOLD}Status Geral: Excelente! O ambiente está pronto para prosseguir.${NC}"
else
    echo -e "${YELLOW}${BOLD}Status Geral: Revise as dicas acima para corrigir os itens apontados.${NC}"
fi
echo -e "${CYAN}${BOLD}================================================================${NC}"
