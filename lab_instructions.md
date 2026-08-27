# Construindo Agentes Autônomos Empresariais com Vertex AI & GEAP

## Visão Geral
Boas-vindas ao laboratório prático da **Google Enterprise Agent Platform (GEAP)**. Neste laboratório, você explorará como construir, validar e implantar agentes de inteligência artificial corporativos utilizando o Vertex AI Agent Engine, Google ADK (Agent Development Kit), salvaguardas de segurança do Model Armor e técnicas de aterramento com Vertex RAG.

Todos os serviços essenciais, configurações de rede, buckets de armazenamento de preparação no Cloud Storage e repositórios de contêineres já foram pré-provisionados automaticamente para você.

## Objetivos
Neste laboratório, você aprenderá a:
* Verificar os serviços e APIs do GEAP e Vertex AI habilitados no seu sandbox.
* Inspecionar manifestos de agentes e repositórios do Artifact Registry pré-criados.
* Interagir com modelos de fundação Vertex AI Gemini a partir do Cloud Shell.
* Explorar endpoints do Vertex AI Agent Engine e do ecossistema ADK.

---

## Credenciais e Detalhes do Ambiente

Os parâmetros do seu sandbox temporário no Google Cloud são exibidos abaixo:

* **ID do Projeto GCP:** `{{{ project_0.project_id }}}`
* **Região Atribuída:** `{{{ project_0.region }}}`
* **Zona Atribuída:** `{{{ project_0.zone }}}`
* **Usuário do Aluno:** `{{{ user_0.username }}}`

> **Importante:** Não utilize sua conta pessoal do Google. Sempre acesse utilizando as credenciais temporárias de estudante fornecidas na barra lateral em uma janela anônima (Incognito/Private).

---

## Tarefa 1: Acessar o Google Cloud Console e o Cloud Shell

1. Clique no botão **Open Google Cloud Console** no painel esquerdo.
2. Faça login utilizando o **Username** e **Password** temporários exibidos na barra lateral do laboratório.
3. Aceite os Termos de Serviço caso solicitado.
4. No canto superior direito do Google Cloud Console, clique em **Ativar Cloud Shell** (`>_`).
5. Execute o comando abaixo para configurar sua região padrão e garantir que o contexto do projeto esteja ativo:

```bash
gcloud config set project {{{ project_0.project_id }}}
gcloud config set compute/region {{{ project_0.region }}}
```

---

## Tarefa 2: Validar os Serviços e APIs Principais do GEAP

O script de inicialização automatizado habilitou previamente todo o ecossistema de APIs para suportar o GEAP e o Vertex AI Agent Engine.

Execute o comando a seguir para verificar se os serviços estão ativos:

```bash
gcloud services list --enabled --filter="name:(aiplatform OR discoveryengine OR modelarmor OR run)"
```

Você verá na saída os seguintes serviços ativos:
* `aiplatform.googleapis.com` (Vertex AI / Reasoning Engines / Agent Engine)
* `discoveryengine.googleapis.com` (Vertex AI Agent Builder / Search & Conversation)
* `modelarmor.googleapis.com` (Salvaguardas de Segurança e Filtros do Model Armor)
* `run.googleapis.com` (Cloud Run para servidores MCP remotos e agentes em contêiner)

---

## Tarefa 3: Inspecionar Artefatos Pré-configurados e o Repositório Docker

1. Verifique o repositório Docker criado no Artifact Registry para hospedar imagens de agentes customizados e servidores remotos do Model Context Protocol (MCP):

```bash
gcloud artifacts repositories describe geap-agent-docker --location={{{ project_0.region }}}
```

2. Inspecione o manifesto de exemplo do agente no bucket de preparação do Cloud Storage:

```bash
export BUCKET_NAME="{{{ project_0.project_id }}}-geap-artifacts"
gcloud storage cat "gs://${BUCKET_NAME}/manifests/agent_manifest.json"
```

---

## Tarefa 4: Testar a Invocação de Modelos Vertex AI Gemini via Cloud Shell

Execute o script Python a seguir no Cloud Shell para enviar uma solicitação com geração estruturada (JSON) para o modelo Gemini 1.5 Flash no Vertex AI:

```bash
python3 -c '
import urllib.request, json, subprocess

token = subprocess.check_output(["gcloud", "auth", "print-access-token"]).decode("utf-8").strip()
project_id = "{{{ project_0.project_id }}}"
region = "{{{ project_0.region }}}"

url = f"https://{region}-aiplatform.googleapis.com/v1/projects/{project_id}/locations/{region}/publishers/google/models/gemini-1.5-flash:generateContent"

payload = {
    "contents": [{"role": "user", "parts": [{"text": "Você é um roteador semântico da plataforma GEAP. Classifique a intenção do usuário: \"Onde está o meu pedido #12345?\" em formato JSON {intent: string, confidence: float, language: string}"}]}],
    "generationConfig": {"responseMimeType": "application/json"}
}

req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"})
with urllib.request.urlopen(req) as resp:
    print(resp.read().decode("utf-8"))
'
```

---

## Tarefa 5: Finalizar o Laboratório

Parabéns! Você validou a infraestrutura do GEAP, inspecionou as configurações pré-provisionadas e testou chamadas aos modelos de linguagem no Vertex AI.

Para encerrar o laboratório:
1. Retorne à aba do **Qwiklabs**.
2. Clique no botão vermelho **End Lab** (Encerrar Laboratório).
3. Confirme para liberar os recursos do sandbox automaticamente.
