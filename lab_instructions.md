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
* Verificar os serviços e APIs do GEAP e Vertex AI habilitados no seu projeto sandbox.
* Inspecionar manifestos de agentes e repositórios do Artifact Registry pré-criados.
* Interagir com modelos de fundação Vertex AI Gemini a partir do Cloud Shell com respostas em JSON estruturado.
* Validar a arquitetura de persistência e repositórios para implantação de agentes e servidores MCP remotos.

---

## Configuração e Pré-requisitos

### Antes de clicar no botão "Start Lab"
Leia estas instruções com atenção. Os laboratórios têm um temporizador regressivo e o ambiente sandbox não pode ser pausado. O cronômetro começa a contar quando você clica em **Start Lab**.

### Parâmetros e Credenciais do seu Sandbox
* **ID do Projeto GCP:** `{{{ project_0.project_id }}}`
* **Região Atribuída:** `{{{ project_0.region }}}`
* **Zona Atribuída:** `{{{ project_0.zone }}}`
* **Usuário do Aluno:** `{{{ user_0.username }}}`
* **Senha:** *(exibida no painel esquerdo após iniciar o lab)*

---

## Como iniciar o laboratório e fazer login no Google Cloud Console

1. Clique no botão **Start Lab** no canto superior esquerdo da página.
2. Aguarde aproximadamente 1 a 2 minutos enquanto o script de automação configura as APIs e o projeto sandbox.
3. Quando o painel esquerdo exibir suas credenciais temporárias:
   * Clique com o **botão direito** no botão **Open Google Cloud Console** (Abrir Console do Google Cloud).
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

## Tarefa 1: Abrir e Autorizar o Google Cloud Shell

O Cloud Shell é uma máquina virtual com ferramentas de desenvolvimento e o SDK `gcloud` pré-instalado.

1. No canto superior direito do Console do Google Cloud, clique no ícone **Ativar Cloud Shell** (`>_`).
2. Quando a janela do terminal abrir na parte inferior da tela, clique em **Continuar (*Continue*)**.
3. Confirme que você está autenticado com o usuário do laboratório:

```bash
gcloud auth list
```
*(A conta ativa exibida deve ser o `{{{ user_0.username }}}`)*.

4. Configure sua região padrão e garanta que o projeto ativo seja o sandbox atribuído:

```bash
gcloud config set project {{{ project_0.project_id }}}
gcloud config set compute/region {{{ project_0.region }}}
```

5. Caso apareça uma janela pop-up solicitando **"Autorizar o Cloud Shell a fazer chamadas de API do GCP"** (*Authorize Cloud Shell to make GCP API calls*), clique em **Autorizar (*Authorize*)**.

---

## Tarefa 2: Validar os Serviços e APIs Principais do GEAP

O script de inicialização automatizado pré-habilitou todo o ecossistema de APIs corporativas do Google Cloud para o GEAP e o Vertex AI Agent Engine.

Execute o comando a seguir no Cloud Shell para verificar os serviços ativos:

```bash
gcloud services list --enabled --filter="name:(aiplatform OR discoveryengine OR modelarmor OR run)"
```

### Serviços esperados na saída:
* `aiplatform.googleapis.com` &rarr; Vertex AI, Reasoning Engines e Agent Engine.
* `discoveryengine.googleapis.com` &rarr; Vertex AI Agent Builder, Search & Conversation e RAG Data Stores.
* `modelarmor.googleapis.com` &rarr; Salvaguardas de segurança corporativas e filtros de prompt injection do Model Armor.
* `run.googleapis.com` &rarr; Cloud Run para hospedagem de servidores remotos MCP e contêineres de agentes customizados.

---

## Tarefa 3: Inspecionar Artefatos Pré-configurados e o Repositório Docker

1. Verifique o repositório Docker criado no Artifact Registry para hospedar imagens de contêiner de agentes e servidores MCP:

```bash
gcloud artifacts repositories describe geap-agent-docker --location={{{ project_0.region }}}
```

2. Inspecione o manifesto de exemplo de agente corporativo armazenado no bucket de preparação do Cloud Storage:

```bash
export BUCKET_NAME="{{{ project_0.project_id }}}-geap-artifacts"
gcloud storage cat "gs://${BUCKET_NAME}/manifests/agent_manifest.json"
```

---

## Tarefa 4: Testar a Invocação de Modelos Vertex AI Gemini via Cloud Shell

Execute o script Python a seguir no Cloud Shell para testar o envio de uma solicitação com geração estruturada (JSON) para o modelo Gemini 1.5 Flash no Vertex AI:

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

Você deverá receber uma resposta em formato JSON categorizando a intenção do usuário com alta confiança.

---

## Tarefa 5: Finalizar o Laboratório

Parabéns! Você acessou o ambiente com segurança em modo anônimo, validou a infraestrutura do GEAP, inspecionou os repositórios pré-provisionados e testou a integração com o modelo Gemini no Vertex AI.

Para liberar os recursos do sandbox:
1. Retorne à aba do navegador do **Qwiklabs**.
2. Clique no botão vermelho **End Lab** (Encerrar Laboratório).
3. Na caixa de diálogo de confirmação, clique em **Submit** para confirmar o encerramento.
4. Feche a janela anônima do navegador.
