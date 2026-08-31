# Implantação de um Agente de Due Diligence com Antigravity CLI e ADK: Laboratório com Desafio

## Informações do Laboratório
* **Tempo estimado:** 1 hora 30 minutos
* **Nível:** `Foundational` / `Intermediate`

---

## Visão Geral

Neste laboratório prático com desafio, você vai demonstrar sua capacidade de usar o **Antigravity CLI (`agy`)** como copiloto de desenvolvimento em terminal para construir um agente inteligente com o **Kit de Desenvolvimento de Agente (ADK)** aproveitando o ecossistema de **Skills** do `agents-cli`.

Você vai integrar uma skill especializada de Due Diligence, testar e refinar o comportamento localmente com a interface **ADK Web**, orquestrar a implantação no **Google Cloud Agent Runtime** diretamente através do assistente `agy` e publicá-lo no **Gemini Enterprise App**.

### Objetivos do Laboratório
Neste laboratório, você vai:
* Configurar o ambiente do Cloud Shell e inicializar o assistente **Antigravity CLI (`agy`)**;
* Instalar o `agents-cli` e habilitar a suíte de skills do ADK para uso no `agy`;
* Criar e estruturar um agente ADK de Due Diligence integrado a skills usando o comando interativo `/grill-me` no `agy`;
* Executar, validar e depurar o fluxo do agente localmente com a interface **ADK Web** e assistência do `agy`;
* Fazer a implantação do agente no **Google Cloud Agent Runtime** utilizando o `agy` e as skills do `agents-cli`;
* Publicar e disponibilizar o agente no **Gemini Enterprise App** conectando o resource name do Agent Runtime.

---

## Configuração e Requisitos

### Painel de Detalhes da Conexão
Para acessar os recursos fornecidos para esta sessão, utilize os valores exibidos abaixo:

<div style="background-color: #f8f9fa; border-left: 4px solid #1a73e8; padding: 12px 16px; margin: 16px 0; border-radius: 4px; font-family: monospace;">
  <ul style="list-style-type: none; margin: 0; padding: 0;">
    <li><strong>ID do Projeto GCP:</strong> <ql-variable key="project_0.project_id"></ql-variable></li>
    <li><strong>Região Atribuída:</strong> <ql-variable key="project_0.default_region"></ql-variable></li>
    <li><strong>Zona Atribuída:</strong> <ql-variable key="project_0.default_zone"></ql-variable></li>
    <li><strong>Usuário Aluno:</strong> <ql-variable key="user_0.username"></ql-variable></li>
  </ul>
</div>

> ⚠️ **MUITO IMPORTANTE:** Utilize sempre uma **Janela Anônima (Incognito)** no navegador Google Chrome para fazer login no Console do Google Cloud. Isso evita conflitos de autenticação entre sua conta pessoal/corporativa e as credenciais temporárias do sandbox. Não cadastre telefones ou autenticação em dois fatores na conta temporária.

---

## Cenário do Desafio

A **Cymbal Technologies** é uma empresa líder em soluções corporativas de tecnologia em nuvem e inteligência artificial sediada no Vale do Silício, em franca expansão global. Com uma estratégia agressiva de fusões, aquisições (M&A) e contratação massiva de fornecedores de tecnologia, os times jurídico e de compliance da Cymbal Technologies estão sobrecarregados com o volume de contratos sociais, termos de confidencialidade e instrumentos societários que precisam ser auditados minuciosamente todos os dias.

Para dar escala a essas auditorias mantendo o mais rigoroso padrão de compliance, a liderança de engenharia designou você como Engenheiro de IA da **Cymbal Technologies**. 

**O seu desafio é criar um agente de Due Diligence usando `agents-cli` e ADK para servir no Gemini Enterprise App da Cymbal Technologies através do Agent Runtime.**

Você será responsável por configurar o assistente **Antigravity CLI (`agy`)**, explorar as skills fornecidas pelo `agents-cli`, utilizar técnicas de prompting e refinamento com o comando `/grill-me` para incorporar a skill de auditoria contratual, testar e depurar a solução localmente, orquestrar o deployment no **Agent Runtime** utilizando as skills do `agy` e disponibilizar o agente diretamente no **Gemini Enterprise** para os colaboradores da Cymbal Technologies.

---

## Tarefa 1: Configuração do Ambiente e Inicialização do Antigravity CLI (`agy`)

Nesta primeira tarefa, você vai inicializar as variáveis de ambiente do sandbox no Cloud Shell, clonar os artefatos do workshop, preparar as ferramentas de linha de comando (`uv` e `agy`) e realizar a ativação do Antigravity CLI.

1. No Console do Google Cloud, abra o **Cloud Shell** clicando no ícone do terminal no canto superior direito.

2. Inicialize as variáveis de ambiente com o projeto sandbox ativo e a região atribuída:

```bash
export PROJECT_ID=$DEVSHELL_PROJECT_ID

# Obter dinamicamente a região atribuída ao sandbox pelo Qwiklabs:
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata[google-compute-default-region])" 2>/dev/null)
export REGION=${REGION:-$(gcloud config get-value compute/region 2>/dev/null)}
export REGION=${REGION:-us-central1}

gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION

echo "=========================================="
echo "Projeto Sandbox Ativo: ${PROJECT_ID}"
echo "Região Ativa:          ${REGION}"
echo "=========================================="
```

*(Dica: A região deve coincidir com a atribuída no painel à esquerda. Se necessário, execute `export REGION="sua-regiao"` para sincronizar manualmente).*

3. Caso apareça uma janela pop-up solicitando **"Autorizar o Cloud Shell a fazer chamadas de API do GCP"** (*Authorize Cloud Shell to make GCP API calls*), clique obrigatoriamente em **Autorizar (*Authorize*)**.

4. Clone o repositório do workshop para obter o contrato de teste e a skill de Due Diligence:

```bash
git clone https://github.com/carlosmscabral/workshop-agy.git ~/workshop-agy
cd ~/workshop-agy
```

5. Instale o gerenciador de pacotes moderno `uv` e a CLI do Antigravity (`agy`):

```bash
# Instalar uv
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env

# Instalar Antigravity CLI (agy)
curl -fsSL https://antigravity.google/cli/install.sh | bash
export PATH="$HOME/.local/bin:$PATH"
```

6. Inicie o setup interativo do **Antigravity CLI**:

```bash
agy
```

7. Siga as 4 etapas de autenticação e consentimento exibidas no terminal:

### Passo 1: Inicialização do setup interativo
Selecione a opção **`2. Use a Google Cloud project`**:
![Passo 1 - Inicialização](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_1.png)

### Passo 2: Autenticação da conta Google Cloud
Selecione **`1. Continue with Google Cloud`**:
![Passo 2 - Autenticação](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_2.png)

### Passo 3: Autorização de permissões de acesso
Abra o link exibido no terminal em uma nova aba da sua Janela Anônima e conceda o consentimento:
![Passo 3 - Permissões](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_3.png)

### Passo 4: Conclusão do setup e definição do Projeto
Cole o ID do seu projeto sandbox (`echo $PROJECT_ID`) no prompt e confirme:
![Passo 4 - Pronto para Uso](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_4.png)

Clique em **Verificar meu progresso** para conferir o objetivo.
*Configurar e ativar o Antigravity CLI.*

---

## Tarefa 2: Instalar o `agents-cli`, habilitar as Skills no `agy` e criar o agente

O `agents-cli` pode ser utilizado de forma autônoma (*standalone*) na linha de comando, mas seu principal diferencial neste fluxo é fornecer um ecossistema completo de **Skills especializadas do Google ADK** diretamente para o Antigravity CLI (`agy`).

1. No terminal do Cloud Shell, execute a instalação e setup do `agents-cli` utilizando o `uvx`:

```bash
uvx google-agents-cli setup
```

Ao concluir o setup, tanto a CLI quanto as **skills do agents-cli** serão instaladas e configuradas automaticamente:
![Instalação do agents-cli e skills](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agents_cli_install.png)

2. Atualize o `PATH` do ambiente:

```bash
export PATH=$PATH:"$HOME/.local/bin"
```

3. Inicie o `agy` e digite o comando `/skills` para verificar as skills do ADK carregadas e disponíveis para o assistente:

```bash
agy
```

> Digite `/skills` no prompt do `agy` para visualizar a lista de skills do `agents-cli` integradas. Pressione `ESC` para fechar o menu de skills.
![Visualização das skills no agy](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_agents_cli.png)

4. Crie o arquivo de variáveis de ambiente `.env` com as configurações dinâmicas do seu projeto Google Cloud:

```bash
cat << EOF > .env
GOOGLE_GENAI_USE_VERTEXAI=TRUE
GOOGLE_CLOUD_PROJECT=${PROJECT_ID}
GOOGLE_CLOUD_LOCATION=${REGION}
MODEL=gemini-2.5-flash
EOF
```

5. No prompt do `agy`, execute o comando `/grill-me` para fazer o alinhamento interativo do design e arquitetura do agente:
> Digite `/grill-me` e responda às perguntas de alinhamento com base na skill em `skills/due-diligence-contract/SKILL.md`.

6. Solicite ao `agy` para criar a estrutura do agente de Due Diligence:
> *"Crie um projeto de agente ADK chamado `due-diligence-agent` utilizando as skills do `agents-cli` e integre os protocolos e regras da skill em `skills/due-diligence-contract`."*

7. Instale as dependências do agente gerado:

```bash
uv sync
```

Clique em **Verificar meu progresso** para conferir o objetivo.
*Instalar ferramentas, verificar skills e criar o agente ADK com a skill de Due Diligence.*

---

## Tarefa 3: Testar e refinar o agente localmente com ADK Web e `agy`

Nesta tarefa, você vai validar o comportamento do agente e suas regras de gating através da interface visual do ADK, utilizando o `agy` para ajustar e refinar qualquer comportamento conforme necessário.

1. No terminal do Cloud Shell, inicie a interface Web do ADK:

```bash
uv run adk web
```

2. No canto superior direito do Cloud Shell, clique no botão **Web Preview** (Visualização na Web) e selecione **Preview on port 8000** (ou acesse a porta informada pelo terminal).

3. Execute os seguintes cenários de validação no chat da interface web:

| Cenário de Teste | Entrada do Usuário | Comportamento Esperado do Agente |
| :--- | :--- | :--- |
| **Teste de Gating Rule** | `Olá, você pode analisar um contrato para mim?` | O agente responde cordialmente solicitando o envio ou texto do contrato antes de carregar instruções adicionais (*Gating Rule*). |
| **Auditoria de Contrato** | *(Enviar o conteúdo ou indicar o documento `docs/sample_contract.pdf`)* | O agente carrega as instruções de `references/workflow.md`, analisa cláusulas societárias, administração, quotas e gera o relatório completo de Due Diligence. |

4. **Refinamento e Depuração com `agy`**:
Após realizar os testes, abra uma segunda aba de terminal ou utilize o `agy` livremente no terminal para investigar comportamentos inesperados, ajustar prompts, corrigir regras de gating ou melhorar a formatação do relatório de auditoria gerado até obter o resultado ideal.

5. Quando concluir os testes, pressione `CTRL+C` no terminal para encerrar o servidor do ADK Web.

Clique em **Verificar meu progresso** para conferir o objetivo.
*Testar, depurar e refinar o agente localmente com ADK Web e Antigravity CLI.*

---

## Tarefa 4: Fazer o deploy do agente no Agent Runtime usando o `agy`

Nesta tarefa, em vez de executar comandos manuais complexos de deploy, você vai solicitar diretamente ao **Antigravity CLI (`agy`)** que utilize suas skills integradas do `agents-cli` (como a skill `google-agents-cli-deploy`) para realizar a implantação do agente no **Google Cloud Agent Runtime**.

1. No terminal, inicie o `agy`:

```bash
agy
```

2. Peça ao `agy` para realizar o deployment do agente no Agent Runtime do seu projeto:
> *"Faça o deploy do agente `due-diligence-agent` no Agent Runtime no projeto `"$(echo $PROJECT_ID)"` na região `"$(echo $REGION)"`."*

> **Observação:** O `agy` utilizará as ferramentas e skills do `agents-cli` para orquestrar a compilação, containerização e implantação no Agent Runtime. Esse processo leva de 3 a 7 minutos.

3. Ao término do deployment, anote o **Resource Name** do agente implantado retornado pelo `agy` (formato: `projects/<PROJECT_ID>/locations/<REGION>/agents/<AGENT_ID>`).

4. Valide a prontidão do agente remoto executando uma consulta de teste diretamente através do `agy`.

Clique em **Verificar meu progresso** para conferir o objetivo.
*Implantar o agente no Google Cloud Agent Runtime utilizando o Antigravity CLI.*

---

## Tarefa 5: Conectar e publicar o agente no Gemini Enterprise App

Nesta tarefa final, você disponibilizará o agente de Due Diligence para os colaboradores da Cymbal Technologies dentro do **Gemini Enterprise**.

1. No Console do Google Cloud, pesquise por **Gemini Enterprise** ou acesse **Agent Builder** / **Discovery Engine**.

2. **Ativação da Licença / Habilitação do GE App:** Se solicitado, habilite o Gemini Enterprise App no seu ambiente:
![Habilitar Gemini Enterprise App](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_enable.png)

3. **Criar uma Instância do App:** Crie um novo aplicativo corporativo (por exemplo, `Cymbal Compliance & Legal Hub`):
![Criar Instância do GE App](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_create.png)

4. **Habilitar Recursos de Agentes:**
* Navegue até a aba **Features** (Recursos) nas configurações do app;
* Ative a funcionalidade de **Agentes** (*Agents*).

5. **Adicionar Agente:**
* Retorne para o menu de **Agentes** do aplicativo e clique em **Criar Novo Agente** / **Adicionar Agente**:
![Adicionar Agente no GE App](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_add_agent.png)

6. **Apontar para o Agent Runtime:**
* Selecione a opção **"Agentes do Agent Runtime"** (*Agent Runtime agents*);
* Cole o **Resource Name** do agente obtido na Tarefa 4:
![Apontar para o Agent Runtime](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_runtime.png)

7. **Teste de Produção:** Inicie uma conversa com o agente no Gemini Enterprise App, envie um trecho do contrato de teste e valide a geração do relatório de Due Diligence em produção corporativa.

Clique em **Verificar meu progresso** para conferir o objetivo.
*Publicar e conectar o agente ao Gemini Enterprise App.*

---

## Parabéns!

Você concluiu com sucesso o laboratório com desafio de **Implantação de Agente de Due Diligence com Antigravity CLI e ADK**!

Neste laboratório, você:
* Configurou e utilizou o **Antigravity CLI (`agy`)** para acelerar o desenvolvimento de agentes em linha de comando;
* Habilitou e visualizou o catálogo de **Skills** do `agents-cli` integradas ao assistente `agy`;
* Criou um agente inteligente com o **Google ADK** integrado à skill de Due Diligence utilizando o comando `/grill-me`;
* Validou e refinou o comportamento do agente localmente através da interface **ADK Web** com assistência do `agy`;
* Orquestrou o deployment no **Google Cloud Agent Runtime** diretamente através do assistente `agy`;
* Publicou e integrou o agente corporativo no **Gemini Enterprise App** para a **Cymbal Technologies**.
