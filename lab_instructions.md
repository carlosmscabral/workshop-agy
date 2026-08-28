# Construindo Agentes Autônomos Empresariais com Vertex AI & GEAP

## Visão Geral
Boas-vindas ao laboratório prático da **Google Enterprise Agent Platform (GEAP)**. Neste laboratório, você explorará como construir, validar e implantar agentes de inteligência artificial corporativos utilizando o Vertex AI Agent Engine, Google ADK (Agent Development Kit), salvaguardas de segurança do Model Armor e técnicas de aterramento com Vertex RAG.

Todos os serviços essenciais, configurações de rede, buckets de armazenamento no Cloud Storage e repositórios de contêineres já foram pré-provisionados automaticamente para você no ambiente sandbox.

⏱️ **Duração do Laboratório:** 60 a 90 minutos  
💰 **Custo:** Gratuito (Ambiente sandbox descartável provisionado pelo Qwiklabs)

---

## Objetivos
Ao final deste laboratório, você será capaz de:
* Acessar o Google Cloud Console utilizando credenciais temporárias em modo anônimo.
* Verificar os serviços e APIs essenciais do GEAP, Vertex AI Agent Engine, Sessions e Telemetria.
* Inspecionar o Chat Engine corporativo pré-criado no Discovery Engine / Agent Builder (`agy-enterprise-app`).
* Baixar e carregar o arquivo de ambiente local (`.env`) e os metadados do **AgentCard** no Cloud Shell.
* Interagir com modelos de fundação Vertex AI Gemini a partir do Cloud Shell com respostas em JSON estruturado.

---

## Configuração e Pré-requisitos

### Antes de clicar no botão "Start Lab"
Leia estas instruções com atenção. Os laboratórios têm um temporizador regressivo e o ambiente sandbox não pode ser pausado. O cronômetro começa a contar quando você clica em **Start Lab**.

### Parâmetros e Credenciais do seu Sandbox

Todos os parâmetros exclusivos da sua sessão temporária são gerados dinamicamente para o seu laboratório:

<div style="background-color: #f8f9fa; border-left: 4px solid #1a73e8; padding: 16px; margin: 16px 0; border-radius: 4px;">
  <p style="margin-top: 0;"><strong>💡 Detalhes de Conexão da sua Sessão:</strong></p>
  <ul style="margin-bottom: 0;">
    <li><strong>ID do Projeto GCP:</strong> <ql-variable key="project_0.project_id"></ql-variable></li>
    <li><strong>Região Atribuída:</strong> <ql-variable key="project_0.default_region"></ql-variable></li>
    <li><strong>Zona Atribuída:</strong> <ql-variable key="project_0.default_zone"></ql-variable></li>
    <li><strong>Usuário do Aluno:</strong> <ql-variable key="user_0.username"></ql-variable></li>
    <li><strong>Senha de Acesso:</strong> Consulte o campo <code>Password</code> na barra lateral esquerda</li>
  </ul>
</div>

<p align="center" style="margin: 25px 0;">
  <a href="https://console.cloud.google.com" target="_blank" rel="noopener noreferrer" style="background-color: #1a73e8; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block; font-weight: bold; font-size: 15px; box-shadow: 0 2px 4px rgba(0,0,0,0.2);">
    🚀 Abrir Google Cloud Console
  </a>
  <br>
  <span style="font-size: 12px; color: #5f6368; display: inline-block; margin-top: 8px;">
    👉 <em>Você pode usar o botão acima ou o botão <strong>Console</strong> na barra lateral esquerda. Sempre clique com o botão direito e selecione <strong>"Abrir link em uma janela anônima"</strong> (Open link in incognito window).</em>
  </span>
</p>

---

## Como iniciar o laboratório e fazer login no Google Cloud Console

1. Clique no botão **Start Lab** no canto superior esquerdo da página.
2. Aguarde aproximadamente 1 a 2 minutos enquanto o script de automação inicializa o ambiente sandbox.
3. Com o laboratório ativo, acesse o console usando o botão azul **Open Google Console** na barra lateral esquerda (ou use o botão acima):
   * Clique com o **botão direito** no botão.
   * Selecione **"Abrir link em uma janela anônima"** (*Open link in incognito window*).

> ⚠️ **MUITO IMPORTANTE:** Sempre utilize uma **Janela Anônima (Incognito)**. Isso evita conflitos de autenticação com sua conta corporativa (@google.com) ou pessoal (@gmail.com) e impede o uso ou cobrança acidental em projetos pessoais.

4. Na página de login do Google:
   * Copie o **Username** (Usuário) do painel do Qwiklabs e cole no campo de e-mail. Clique em **Avançar (Next)**.
   * Copie a **Password** (Senha) do painel do Qwiklabs e cole no campo de senha. Clique em **Avançar (Next)**.
   * *(Se aparecer a tela "Escolher uma conta", selecione "Usar outra conta").*

---

## O que aceitar e confirmar nas telas iniciais de acesso

Ao fazer login pela primeira vez com o usuário temporário do laboratório, você passará por algumas telas de confirmação:

1. **Tela "Bem-vindo à sua nova conta" (*Welcome to your new account*):**
   * Clique em **Entendi / Aceitar (*I understand / Accept*)** para concordar com os termos de uso da conta educacional descartável.

2. **Tela "Proteja sua conta" (*Protect your account / Recovery phone or email*):**
   * **NÃO adicione** seu número de telefone pessoal, e-mail de recuperação ou autenticação em dois fatores (2FA).
   * Clique em **"Agora não"**, **"Atualizar mais tarde"** ou **"Confirmar"** (*Not now / Update later / Confirm*) para pular essa etapa. Como esta conta expira ao final do lab, não é necessário cadastrar recuperação.

3. **Termos de Serviço do Google Cloud Console (*Terms of Service*):**
   * No Console do Cloud, marque a caixa de seleção concordando com os **Termos de Serviço**.
   * Selecione o seu país de residência e clique em **Concordar e Continuar (*Agree and Continue*)**.

4. **Banner de Teste Gratuito (*Free Trial*):**
   * **NÃO clique** em "Experimente gratuitamente" (*Try for free*) nem cadastre cartões de crédito. O projeto sandbox já está totalmente financiado e liberado para o laboratório.

---

## Tarefa 1: Abrir e Configurar o Google Cloud Shell

O Cloud Shell é um terminal interativo no navegador com as ferramentas `gcloud` e utilitários de desenvolvimento pré-instalados.

1. No canto superior direito do Console do Google Cloud, clique no ícone **Ativar Cloud Shell** (`>_`).
2. Quando a janela do terminal abrir na parte inferior da tela, clique em **Continuar (*Continue*)**.
3. Confirme que você está autenticado com o usuário do laboratório:

```bash
gcloud auth list
```

*(A conta ativa assinalada com um asterisco deve coincidir com o usuário indicado na barra lateral esquerda).*

4. Inicialize as variáveis de ambiente com o projeto sandbox ativo e a região atribuída:

```bash
export PROJECT_ID=$DEVSHELL_PROJECT_ID
export REGION="us-west1"

gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION

echo "=========================================="
echo "Projeto Sandbox Ativo: ${PROJECT_ID}"
echo "Região Ativa:          ${REGION}"
echo "=========================================="
```

5. Caso apareça uma janela pop-up solicitando **"Autorizar o Cloud Shell a fazer chamadas de API do GCP"** (*Authorize Cloud Shell to make GCP API calls*), clique em **Autorizar (*Authorize*)**.

---

## Tarefa 2: Validar os Serviços e APIs Principais do GEAP

O script de inicialização automatizado pré-habilitou todo o ecossistema de APIs corporativas do Google Cloud para o GEAP, Vertex AI Agent Engine, Sessions e Telemetria.

Execute o comando a seguir no Cloud Shell para verificar os serviços ativos:

```bash
gcloud services list --enabled --filter="name:(aiplatform.googleapis.com OR discoveryengine.googleapis.com OR cloudaicompanion.googleapis.com OR modelarmor.googleapis.com OR run.googleapis.com OR logging.googleapis.com OR cloudtrace.googleapis.com)"
```

### Principais serviços ativos e sua função na arquitetura:
* `aiplatform.googleapis.com` &rarr; Vertex AI Agent Engine, Reasoning Engines, Sessions Service e inferência de modelos Gemini.
* `discoveryengine.googleapis.com` &rarr; Google Enterprise Agent Builder, Search & Conversation e GE App.
* `cloudaicompanion.googleapis.com` &rarr; Integração nativa do Gemini Enterprise App e Cloud Companion.
* `modelarmor.googleapis.com` &rarr; Salvaguardas de segurança corporativas e filtros de prompt injection do Model Armor.
* `cloudtrace.googleapis.com` & `logging.googleapis.com` &rarr; Telemetria unificada, rastreamento distribuído e auditoria de execução de agentes.
* `run.googleapis.com` &rarr; Cloud Run para hospedagem de servidores remotos MCP e serviços de agentes.

---

## Tarefa 3: Inspecionar o GE App (Discovery Engine / Gemini Enterprise)

O script de inicialização pré-criou automaticamente uma aplicação corporativa no Discovery Engine (`agy-enterprise-app`) para registro e roteamento dos seus agentes autônomos.

Inspecione os metadados do GE App executando a chamada REST a seguir diretamente no Cloud Shell:

```bash
curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)"   -H "X-Goog-User-Project: ${DEVSHELL_PROJECT_ID}"   "https://discoveryengine.googleapis.com/v1/projects/${DEVSHELL_PROJECT_ID}/locations/global/collections/default_collection/engines/agy-enterprise-app" | python3 -m json.tool
```

Verifique na saída JSON que a aplicação está configurada corretamente:
* `displayName`: `"AGY Enterprise Agent App"`
* `solutionType`: `"SOLUTION_TYPE_SEARCH"`
* `appType`: `"APP_TYPE_INTRANET"`
* `observabilityConfig.observabilityEnabled`: `true`
* `marketplaceAgentVisibility`: `"SHOW_ALL_AGENTS"`
* O motor está provisionado no Discovery Engine sem data stores, pronto para registro dos agentes ADK via `agents-cli publish gemini-enterprise`.

---

## Tarefa 4: Criar o Ambiente Local (.env e agent_card.json)

Prepare o seu diretório de trabalho local no Cloud Shell e gere os arquivos de configuração para uso com o Google ADK:

```bash
mkdir -p ~/agy-agent && cd ~/agy-agent

cat << 'EOF' > .env
PROJECT_ID=$DEVSHELL_PROJECT_ID
REGION=us-west1
APP_ID=agy-enterprise-app
GEMINI_MODEL=gemini-flash-3.7
VERTEX_LOCATION=global
EOF

source .env

echo "Configurações carregadas localmente no .env:"
cat .env
```

Crie o arquivo de metadados do **AgentCard** que descreve o agente especialista para a plataforma GEAP:

```bash
cat << EOF > agent_card.json
{
  "name": "AGY Due Diligence Specialist Agent",
  "description": "Autonomous enterprise agent developed with Google ADK for due diligence analysis and multi-turn reasoning.",
  "version": "1.0.0",
  "runtime": "Vertex AI Agent Engine (GEAP)",
  "appId": "agy-enterprise-app",
  "project": "${DEVSHELL_PROJECT_ID}",
  "region": "us-west1",
  "capabilities": [
    "autonomous_reasoning",
    "session_persistence",
    "telemetry_logging"
  ]
}
EOF

cat agent_card.json | python3 -m json.tool
```

---

## Tarefa 5: Testar a Invocação de Modelos Vertex AI Gemini via Cloud Shell

Crie e execute o script Python a seguir no Cloud Shell para testar o envio de uma solicitação com geração estruturada (JSON) para o modelo **Gemini 3.7 Flash** no Vertex AI na região **global**, simulando o classificador semântico do agente:

```bash
cat << 'EOF' > test_gemini.py
import subprocess
import json
import urllib.request
import urllib.error

# Obter credenciais ativas do Cloud Shell
token = subprocess.check_output(["gcloud", "auth", "print-access-token"]).decode("utf-8").strip()
project_id = subprocess.check_output(["gcloud", "config", "get-value", "project"]).decode("utf-8").strip()

# Endpoint fixo na região global para o modelo Gemini 3.7 Flash
model = "gemini-flash-3.7"
url = f"https://aiplatform.googleapis.com/v1/projects/{project_id}/locations/global/publishers/google/models/{model}:generateContent"

payload = {
    "contents": [{"role": "user", "parts": [{"text": "Você é um roteador semântico da plataforma GEAP. Classifique a intenção do usuário: 'Onde está o meu pedido #12345?' em formato JSON {intent: string, confidence: float, language: string}"}]}],
    "generationConfig": {"responseMimeType": "application/json"}
}

req = urllib.request.Request(
    url,
    data=json.dumps(payload).encode("utf-8"),
    headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
)

try:
    with urllib.request.urlopen(req) as resp:
        print(resp.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    # Suporte para o alias gemini-3.7-flash caso haja variação de registro
    url_alt = f"https://aiplatform.googleapis.com/v1/projects/{project_id}/locations/global/publishers/google/models/gemini-3.7-flash:generateContent"
    req_alt = urllib.request.Request(
        url_alt,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req_alt) as resp:
        print(resp.read().decode("utf-8"))
EOF

python3 test_gemini.py
```

Você deverá receber uma resposta em formato JSON categorizando a intenção do usuário com alta confiança.

---

## Tarefa 6: Finalizar o Laboratório

Parabéns! Você acessou o ambiente com segurança em modo anônimo, validou a infraestrutura do GEAP, inspecionou a aplicação pré-provisionada no Discovery Engine e testou a integração com o modelo Gemini 3.7 Flash no Vertex AI.

Para liberar os recursos do sandbox:
1. Retorne à aba do navegador do **Qwiklabs**.
2. Clique no botão vermelho **End Lab** (Encerrar Laboratório).
3. Na caixa de diálogo de confirmação, clique em **Submit** para confirmar o encerramento.
4. Feche a janela anônima do navegador.
