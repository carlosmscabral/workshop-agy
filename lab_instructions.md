# Implantação de um Agente de Due Diligence com Antigravity CLI e ADK: Laboratório com Desafio

## Informações do Laboratório

- **Tempo estimado:** 1 hora 30 minutos
- **Nível:** `Foundational` / `Intermediate`

---

## Visão Geral

Neste laboratório prático com desafio, você vai demonstrar sua capacidade de usar o **Antigravity CLI (`agy`)** como copiloto de desenvolvimento em terminal para construir um agente inteligente com o **Kit de Desenvolvimento de Agente (ADK)** aproveitando o ecossistema de **Skills** do `agents-cli`.

Você vai integrar uma skill especializada de Due Diligence, testar e refinar o comportamento localmente com a interface **ADK Web**, orquestrar a implantação no **Google Cloud Agent Runtime** diretamente através do assistente `agy` e publicá-lo no **Gemini Enterprise App**.

### Arquitetura da Solução e Fluxo de Componentes

O diagrama a seguir ilustra a jornada de ponta a ponta que você percorrerá neste laboratório, desde o desenvolvimento no Cloud Shell até a disponibilização do agente para os colaboradores corporativos no Gemini Enterprise:

![Arquitetura da Solução e Fluxo de Componentes](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/architecture_overview.png)

### Modelo Mental: Do Desenvolvimento Tradicional ao Mundo de Agentes

Se você tem experiência com desenvolvimento de software tradicional (APIs REST, frameworks web e scripts), utilize a tabela abaixo como mapa conceitual para conectar os conceitos deste laboratório ao seu conhecimento prévio:

| Conceito no Workshop | Equivalente no Desenvolvimento Tradicional | Papel no Ciclo de Vida do Agente |
| :--- | :--- | :--- |
| **Antigravity CLI (`agy`)** | Copiloto / Par programador no terminal | Seu assistente interativo que gera código, refina regras e orquestra comandos no terminal. |
| **Google ADK** | Framework backend (ex: FastAPI, Express, Flask) | Kit de desenvolvimento em Python que estrutura a lógica, ciclo de vida e estado do agente. |
| **Skills (`SKILL.md`)** | Middlewares de negócio / Manuais de compliance | Pacotes em Markdown com regras e diretrizes que o agente consulta para auditar contratos. |
| **Comando `/grill-me`** | Refinamento de requisitos com Tech Lead | Entrevista socrática que alinha escopo, entradas, saídas e regras de segurança antes de codificar. |
| **ADK Web** | Servidor local com UI (Swagger / Postman) | Interface web local para testar e depurar o agente no navegador antes do deploy na nuvem. |
| **Agent Runtime** | Plataforma Serverless gerenciada (ex: Cloud Run) | Ambiente de nuvem gerenciado que hospeda o contêiner do seu agente com segurança e escala. |
| **Gemini Enterprise App** | Portal corporativo / Frontend da empresa | Ponto de contato final onde os colaboradores da empresa conversam com o agente integrado. |

### Objetivos do Laboratório

Neste laboratório, você aprende a realizar as seguintes tarefas:

- Configurar o ambiente do Cloud Shell e inicializar o assistente **Antigravity CLI (`agy`)**.
- Instalar o `agents-cli` e habilitar a suíte de skills do ADK para uso no `agy`.
- Criar e estruturar um agente ADK de Due Diligence integrado a skills usando o comando interativo `/grill-me` no `agy`.
- Executar, validar e depurar o fluxo do agente localmente com a interface **ADK Web** com assistência do `agy`.
- Fazer a implantação do agente no **Google Cloud Agent Runtime** utilizando o `agy` e as skills do `agents-cli`.
- Publicar e disponibilizar o agente no **Gemini Enterprise App** conectando o resource name do Agent Runtime.

---

## Configuração e Requisitos

### Antes de clicar no botão Iniciar laboratório

Leia atentamente estas instruções. Os laboratórios são cronometrados e não podem ser pausados. O temporizador é iniciado assim que você clica em **Iniciar laboratório** e indica por quanto tempo os recursos do Google Cloud permanecerão disponíveis para você.

Este laboratório prático permite realizar as atividades em um ambiente real de nuvem, e não em uma simulação ou demonstração. Você receberá novas credenciais temporárias para fazer login e acessar o Google Cloud durante a sessão.

Para concluir este laboratório, você precisa de:

- Acesso a um navegador de internet padrão (recomendamos o Google Chrome).
- Tempo suficiente para concluir o roteiro — lembre-se de que não é possível pausar um laboratório em andamento.

> ⚠️ **MUITO IMPORTANTE — Janela Anônima Obrigatória:**  
> Utilize sempre uma **Janela Anônima (Incognito)** ou privada do navegador Google Chrome para executar este laboratório. Isso evita conflitos de autenticação entre sua conta pessoal/corporativa e a conta de estudante temporária, prevenindo cobranças indevidas em sua conta pessoal.

> 🔒 **Uso Exclusivo da Conta de Estudante:**  
> Utilize estritamente as credenciais fornecidas no painel do laboratório. Se você utilizar sua conta pessoal do Google Cloud, cobranças poderão ser geradas diretamente nela.

### Painel de Detalhes da Conexão

Para acessar os recursos fornecidos para esta sessão, utilize os valores exibidos abaixo:

<div style="background-color: #f8f9fa; border-left: 4px solid #1a73e8; padding: 12px 16px; margin: 16px 0; border-radius: 4px; font-family: monospace;">
  <ul style="list-style-type: none; margin: 0; padding: 0;">
    <li><strong>ID do Projeto GCP:</strong> <ql-variable key="project_0.project_id"></ql-variable></li>
    <li><strong>Região Atribuída:</strong> <ql-variable key="project_0.default_region"></ql-variable></li>
    <li><strong>Zona Atribuída:</strong> <ql-variable key="project_0.default_zone"></ql-variable></li>
    <li><strong>Usuário Aluno:</strong> <ql-variable key="user_0.username"></ql-variable></li>
    <li><strong>Senha de Acesso:</strong> Consulte o campo <em>Password</em> no painel lateral esquerdo</li>
  </ul>
</div>

### Fazer login no Console do Google Cloud

1.  No painel lateral esquerdo do laboratório, clique com o botão direito no botão **Abrir console do Google Cloud** e selecione **Abrir link em janela anônima**.

2.  Se a página exibir a caixa de diálogo **Escolher uma conta** (*Choose an account*), clique em **Usar outra conta** (*Use another account*):  
   ![Escolher uma conta - Usar outra conta](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/google_choose_account.png)

3.  Na tela de login do Google, cole o **Nome de usuário** temporário (<ql-variable key="user_0.username"></ql-variable>) e clique em **Avançar** (*Next*).

4.  Cole a **Senha** temporária fornecida no painel e clique em **Avançar** (*Next*).

5.  Conclua as telas de boas-vindas seguintes da conta temporária:
   - Na tela **Bem-vindo à sua nova conta** (*Welcome to your new account*), clique em **Entendi** ou **Aceitar** (*I understand* / *Accept*);
   - Na tela **Proteja sua conta** (*Protect your account*), **NÃO** adicione telefone de recuperação ou autenticação em duas etapas (2FA) — clique em **Atualizar mais tarde** ou **Agora não** (*Update later* / *Not now*);
   - Na tela **Termos de Serviço** do Google Cloud Console, marque a caixa de seleção concordando com os termos e clique em **Concordar e continuar** (*Agree and Continue*), sem se inscrever em períodos de teste gratuito (*Free Trial*).

Após alguns instantes, o Console do Google Cloud será aberto nesta aba anônima.

> 💡 **Dica de Navegação no Console do Google Cloud:**  
> Para acessar qualquer produto ou serviço do Google Cloud ao longo do laboratório, clique no **Menu de navegação** (`☰`) no canto superior esquerdo ou digite o nome do serviço diretamente no campo **Pesquisar** (`Search (/)`):  
> ![Menu de navegação e barra de pesquisa do Console](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/console_topbar_menu.png)

> ℹ️ **Aviso sobre Respostas de Modelos:**  
> Para garantir uma experiência consistente e de alto desempenho durante a execução em turmas com múltiplos alunos simultâneos, este laboratório inclui respostas pré-armazenadas para assegurar a continuidade das atividades.

---

## Cenário do Desafio

A **Cymbal Technologies** é uma empresa líder em soluções corporativas de tecnologia em nuvem e inteligência artificial sediada no Vale do Silício, em franca expansão global. Com uma estratégia agressiva de fusões, aquisições (M&A) e contratação massiva de fornecedores de tecnologia, os times jurídico e de compliance da Cymbal Technologies estão sobrecarregados com o volume de contratos sociais, termos de confidencialidade e instrumentos societários que precisam ser auditados minuciosamente todos os dias.

Para dar escala a essas auditorias mantendo o mais rigoroso padrão de compliance, a liderança de engenharia designou você como Engenheiro de IA da **Cymbal Technologies**. 

**O seu desafio é criar um agente de Due Diligence usando `agents-cli` e ADK para servir no Gemini Enterprise App da Cymbal Technologies através do Agent Runtime.**

Você será responsável por configurar o assistente **Antigravity CLI (`agy`)**, explorar as skills fornecidas pelo `agents-cli`, utilizar técnicas de prompting e refinamento com o comando `/grill-me` para incorporar a skill de auditoria contratual, testar e depurar a solução localmente, orquestrar o deployment no **Agent Runtime** utilizando as skills do `agy` e disponibilizar o agente diretamente no **Gemini Enterprise** para os colaboradores da Cymbal Technologies.

---

## Tarefa 1. Configurar o ambiente e inicializar o Antigravity CLI

Nesta tarefa, você inicializa as variáveis do Cloud Shell, clona os artefatos do workshop, instala as ferramentas CLI (`uv`, `agy` e `agents-cli`) e autentica o assistente de desenvolvimento no seu projeto Google Cloud.

> 💡 **Guia Visual de Ambientes de Execução:**  
> Para evitar confusões entre os diferentes ambientes ao longo do laboratório, observe o distintivo no início de cada passo:  
> - 💻 **Terminal Cloud Shell (`$`):** Comandos padrão do shell Linux no Google Cloud Shell.  
> - 🤖 **Prompt do Antigravity CLI (`agy >`):** Comandos e prompts executados dentro da sessão interativa do assistente `agy`.  
> - 🌐 **Navegador Web / ADK Web:** Ações na interface visual do navegador ou no chat do ADK Web.  
> - ☁️ **Console Google Cloud:** Navegação e ações na interface gráfica administrativa do Google Cloud Console.

### Ativar o Cloud Shell e inicializar variáveis

1.  ☁️ **Console Google Cloud:** No canto superior direito do Console do Google Cloud, clique no botão **Ativar o Cloud Shell** ![Ícone Ativar o Cloud Shell](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/devshell.png).

2.  ☁️ **Console Google Cloud:** Na janela informativa do Cloud Shell, clique em **Continuar** (*Continue*):  
   ![Continuar no Cloud Shell](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/cloudshell_continue.png)

3.  💻 **Terminal Cloud Shell (`$`):** Inicialize as variáveis de ambiente com o projeto sandbox ativo e a região atribuída (persistindo no `~/.bashrc` para que novas abas do terminal herdem os valores). **Atenção:** Quando o primeiro comando `gcloud` exibir a janela pop-up **"Autorizar o Cloud Shell a fazer chamadas de API do GCP"** (*Authorize Cloud Shell to make GCP API calls*), clique obrigatoriamente em **Autorizar** (*Authorize*):

    ```bash
    export PROJECT_ID=$DEVSHELL_PROJECT_ID

    # Obter dinamicamente a região e zona atribuídas ao sandbox pelo Qwiklabs:
    export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata[google-compute-default-region])" 2>/dev/null)
    export REGION=${REGION:-$(gcloud config get-value compute/region 2>/dev/null)}
    export REGION=${REGION:-us-central1}

    export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata[google-compute-default-zone])" 2>/dev/null)
    export ZONE=${ZONE:-${REGION}-a}

    gcloud config set project $PROJECT_ID
    gcloud config set compute/region $REGION
    gcloud config set compute/zone $ZONE

    cat << EOF >> ~/.bashrc
    export PROJECT_ID=${PROJECT_ID}
    export REGION=${REGION}
    export ZONE=${ZONE}
    export PATH="\$HOME/.local/bin:\$PATH"
    EOF

    echo "=========================================="
    echo "Projeto Sandbox Ativo: ${PROJECT_ID}"
    echo "Região Ativa:          ${REGION}"
    echo "Zona Ativa:            ${ZONE}"
    echo "=========================================="
    ```

4.  💻 **Terminal Cloud Shell (`$`):** Clone o repositório do workshop para obter o contrato de amostra e a skill de Due Diligence:

    ```bash
    git clone https://github.com/carlosmscabral/workshop-agy.git ~/workshop-agy
    cd ~/workshop-agy
    ```

### Instalar ferramentas e autenticar o Antigravity CLI

> ℹ️ **Avisos de Instalação e Atalhos de Cópia/Colagem no Terminal:**  
> - Se o terminal informar que o `uv` ou o `agy` já estão instalados (*`already installed`*), desconsidere o aviso e prossiga normalmente.  
> - **Cuidado com `CTRL+C` no terminal:** No Cloud Shell, `CTRL+C` interrompe o programa em execução. Para abrir links exibidos no terminal, use **`CTRL+Clique`** (ou **`CMD+Clique`** no Mac); para colar textos ou códigos de autorização no terminal, use **`CTRL+SHIFT+V`** (Windows/Linux) ou **`CMD+V`** (Mac).

1.  💻 **Terminal Cloud Shell (`$`):** Instale o gerenciador de pacotes moderno `uv`:

    ```bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.local/bin/env
    ```

2.  💻 **Terminal Cloud Shell (`$`):** Instale a ferramenta de linha de comando do Antigravity (`agy`):

    ```bash
    curl -fsSL https://antigravity.google/cli/install.sh | bash
    export PATH="$HOME/.local/bin:$PATH"
    ```

3.  💻 **Terminal Cloud Shell (`$`):** Inicie o setup interativo do **Antigravity CLI**:

    ```bash
    agy
    ```

4.  🤖 **Setup Interativo do Antigravity CLI (`agy`):** Siga as 9 etapas de autenticação, configuração e inicialização exibidas no terminal:

- **Passo 1:** Selecione a opção **`2. Use a Google Cloud project`**:  
  ![Passo 1 - Inicialização](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_1.png)

- **Passo 2:** Selecione a opção **`1. Continue with Google Cloud`**:  
  ![Passo 2 - Autenticação](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_2.png)

- **Passo 3:** Abra o link de autorização exibido no terminal (`CTRL+Clique` ou `CMD+Clique`) em uma nova aba da sua Janela Anônima, selecione a conta de estudante <ql-variable key="user_0.username"></ql-variable>, conceda o consentimento e cole o código de autorização de volta no terminal (`CTRL+SHIFT+V` ou `CMD+V`):  
  ![Passo 3 - Permissões](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_3.png)

- **Passo 4:** Cole (`CTRL+SHIFT+V` ou `CMD+V`) o ID do seu projeto sandbox (<ql-variable key="project_0.project_id"></ql-variable>) no prompt e confirme pressionando `ENTER`:  
  ![Passo 4 - ID do Projeto](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_4.png)

- **Passo 5:** Em **Select Google Cloud Location**, selecione a opção **`global`** e confirme pressionando `ENTER`:  
  ![Passo 5 - Região Global](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_5.png)

- **Passo 6:** Em **Select License**, selecione a opção **`1. Agent Platform`** e confirme pressionando `ENTER`:  
  ![Passo 6 - Seleção de Licença](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_6.png)

- **Passo 7:** Em **Choose your color scheme**, selecione o tema de cores de sua preferência (como **`dark`**) e confirme pressionando `ENTER`:  
  ![Passo 7 - Tema Visual](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_7.png)

- **Passo 8:** Na tela **Terms of Service & Data Use**, navegue até a opção **`Done`** e confirme pressionando `ENTER` para aceitar os termos de serviço:  
  ![Passo 8 - Termos de Serviço](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_8.png)

- **Passo 9:** Na tela de confirmação **Do you trust the contents of this project?**, selecione **`Yes, I trust this folder`** e confirme pressionando `ENTER` para liberar o acesso ao workspace:  
  ![Passo 9 - Confiança no Workspace](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_9.png)

> 💡 **Ambiente Ativo ao Final da Tarefa 1:**  
> Ao concluir o Passo 9 da autenticação, você estará conectado dentro da sessão interativa do assistente, indicada pelo prompt `agy >`.

> 💡 **Comandos Úteis do Antigravity CLI (`agy`):**
> 
> | Comando / Atalho | Ação Executada |
> | :--- | :--- |
> | `/skills` | Lista todas as skills instaladas e ativas no ambiente |
> | `/grill-me` | Inicia o alinhamento interativo do design e arquitetura do plano |
> | `/clear` | Limpa o histórico da conversa atual no terminal |
> | `/exit` / `CTRL+C` | Sai do prompt do `agy` e retorna para o shell |

> ⚠️ **Solução de Problemas de Autenticação no Antigravity CLI:**  
> Se o assistente apresentar erros como `Permission 'aiplatform.endpoints.predict' denied` ou `Agent terminated due to error`, execute `agy auth logout` no terminal e reinicie o assistente com `agy`, garantindo o login com a conta temporária <ql-variable key="user_0.username"></ql-variable>.

### Explorar comandos básicos do agy e a estrutura da Skill

1.  🤖 **Prompt do Antigravity CLI (`agy >`):** Execute o comando `/help` para conhecer os atalhos, comandos interativos (`/skills`, `/config`, `/grill-me`, `/clear`, `/exit`) e recursos nativos do assistente:

    ```text
    /help
    ```

2.  🤖 **Prompt do Antigravity CLI (`agy >`):** Faça um teste rápido de leitura de contexto enviando o prompt abaixo para que o `agy` inspecione a skill pré-fornecida no repositório:

    ```text
    Leia o arquivo skills/due-diligence-contract/SKILL.md e resuma em 3 tópicos como funciona a regra de Gating deste agente.
    ```

3.  🤖 **Prompt do Antigravity CLI (`agy >`):** Após conferir a resposta do assistente, saia da sessão interativa digitando `/exit` para retornar ao prompt do terminal do Cloud Shell (`$`):

    ```text
    /exit
    ```

4.  📝 **Editor do Cloud Shell:** Na barra superior do Cloud Shell, clique no botão **Abrir Editor** (*Open Editor*) ![Ícone Open Editor](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/cloud_shell_editor.png). Na árvore de arquivos à esquerda, expanda `workshop-agy` → `skills` → `due-diligence-contract` e clique em **`SKILL.md`** para visualizar como uma skill do ADK é estruturada (metadados YAML no topo, seção `<gating_rule>` e ponteiros de contexto progressivo para `references/workflow.md` e `references/checklist.md`). Em seguida, clique no botão **Abrir Terminal** (*Open Terminal*) na barra superior direita do Cloud Shell para voltar ao prompt (`$`):  
   ![Visualização da skill SKILL.md no Editor do Cloud Shell](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/editor_skill_md.png)

---

## Tarefa 2. Instalar o agents-cli, habilitar skills e criar o agente

Nesta tarefa, você instala o `agents-cli`, valida obrigatoriamente o catálogo de skills do ADK no assistente `agy`, utiliza o comando `/grill-me` para alinhar e gerar a arquitetura do agente de Due Diligence, configura o ambiente com o modelo `gemini-flash-3.8` na região `global` e inspeciona o código gerado em `app/agent.py`.

> 💡 **O que são ADK Skills ([adk.dev/skills](https://adk.dev/skills/))?**  
> As **Skills do ADK** são pacotes modulares que encapsulam diretrizes operacionais, checklists e fluxos de negócio em arquivos Markdown (`SKILL.md` e `references/`). Elas permitem que o agente opere com contexto progressivo (*progressive disclosure*), consultando conhecimentos especializados sob demanda sem sobrecarregar a janela de contexto principal.

### Habilitar skills e alinhar o agente com /grill-me

1.  💻 **Terminal Cloud Shell (`$`):** No terminal do Cloud Shell, instale e configure o `agents-cli` utilizando o `uvx` e atualize o `PATH`:

    ```bash
    uvx google-agents-cli setup
    export PATH="$HOME/.local/bin:$PATH"
    ```

2.  💻 **Terminal Cloud Shell (`$`):** Confirme na saída do terminal que a CLI e as **skills do `agents-cli`** foram instaladas e vinculadas automaticamente (conforme a imagem abaixo) e inicie novamente o assistente `agy`:  
   ![Instalação do agents-cli e skills](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agents_cli_install.png)

    ```bash
    agy
    ```

3.  🤖 **Prompt do Antigravity CLI (`agy >`):** **Verificar as Skills Instaladas (Obrigatório):** Com o `agy` aberto, execute obrigatoriamente o comando `/skills` para validar que o catálogo de skills do `agents-cli` foi integrado ao seu ambiente:

    ```text
    /skills
    ```

4.  🤖 **Prompt do Antigravity CLI (`agy >`):** Confirme na tela que as **7 skills** (`google-agents-cli-*`) aparecem listadas no workspace (conforme a imagem abaixo), pressione `ESC` para fechar o menu de skills e, em seguida, execute o comando `/config`:  
   ![Visualização das skills no agy](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_agents_cli.png)

    ```text
    /config
    ```

5.  🤖 **Prompt do Antigravity CLI (`agy >`):** **Configurar Modo Permissivo de Ferramentas (`always-proceed`):** No menu aberto pelo `/config`, navegue até a opção **Tool Permission**, altere para **`always-proceed`** (para que o assistente crie pastas, escreva arquivos e execute comandos com autonomia sem solicitar aprovação manual a cada ação), pressione `ESC` para fechar o menu e execute o comando `/grill-me`:  
   ![Configuração de Permissão de Ferramentas no agy](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_config_tool_permission.png)

    ```text
    /grill-me
    ```

6.  🤖 **Prompt do Antigravity CLI (`agy >`):** Durante a execução do `/grill-me`, utilize as seguintes respostas recomendadas baseadas na skill em `skills/due-diligence-contract/SKILL.md`:
   - **Objetivo central:** *Auditar contratos sociais e minutas societárias para identificar riscos jurídicos, cláusulas de administração e restrições de quotas.*
   - **Ferramentas e skills:** *Utilizar a especificação formal de ADK Skills ([adk.dev/skills](https://adk.dev/skills/)), incorporando o pacote de skill em `skills/due-diligence-contract/SKILL.md` e os templates do `agents-cli`.*
   - **Regra de gating de entrada:** *O agente só deve carregar o checklist detalhado após receber um contrato ou texto jurídico válido do usuário.*
   - **Formato de saída esperado:** *Relatório estruturado em Markdown com classificação de risco (Alto/Médio/Baixo) e recomendações práticas.*

7.  🤖 **Prompt do Antigravity CLI (`agy >`):** Concluído o alinhamento com o `/grill-me`, envie a seguinte instrução no prompt do `agy` para gerar o projeto do agente:

    ```text
    Crie um projeto de agente ADK chamado due-diligence-agent seguindo a especificação oficial de ADK Skills (adk.dev/skills) e as convenções do agents-cli. O agente deve carregar a skill especializada localizada em skills/due-diligence-contract/SKILL.md (ou ../skills/due-diligence-contract/SKILL.md a partir da subpasta due-diligence-agent), respeitar estritamente a regra de gating (não carregar instruções detalhadas antes que um contrato seja enviado) e consultar references/workflow.md para estruturar o relatório de auditoria.
    ```

8.  🤖 **Prompt do Antigravity CLI (`agy >`):** Saia do assistente digitando `/exit` no prompt do `agy` para retornar ao terminal do Cloud Shell:

    ```text
    /exit
    ```

9.  💻 **Terminal Cloud Shell (`$`):** Acesse o diretório do agente recém-criado e crie o arquivo de configuração `.env` diretamente no seu local definitivo, definindo a região fixa como `global` e o modelo como `gemini-flash-3.8`:

    ```bash
    cd ~/workshop-agy/due-diligence-agent

    cat << EOF > .env
    GOOGLE_GENAI_USE_VERTEXAI=TRUE
    GOOGLE_CLOUD_PROJECT=${PROJECT_ID}
    GOOGLE_CLOUD_LOCATION=global
    MODEL=gemini-flash-3.8
    EOF
    ```

10. 💻 **Terminal Cloud Shell (`$`):** Sincronize as dependências do projeto com o `uv`:

    ```bash
    uv sync
    ```

11. 📝 **Editor do Cloud Shell:** Antes de testar o agente, clique novamente no botão **Abrir Editor** (*Open Editor*) ![Ícone Open Editor](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/cloud_shell_editor.png) na barra superior do Cloud Shell. Na árvore de arquivos à esquerda, expanda a pasta recém-gerada `due-diligence-agent/app/` e abra o arquivo **`agent.py`** para inspecionar o código Python criado pelo `agy` (observe a definição do `root_agent` com o SDK `google.adk`, o modelo configurado e a integração da skill). Após explorar o código, clique no botão **Abrir Terminal** (*Open Terminal*) na barra superior para retornar ao terminal (`$`):  
   ![Inspeção do arquivo agent.py no Editor do Cloud Shell](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/editor_agent_py.png)

---

## Tarefa 3. Testar e refinar o agente localmente com ADK Web

Nesta tarefa, você valida o comportamento do agente e suas regras de gating através da interface visual do ADK Web, utilizando o `agy` para depurar e refinar qualquer resposta conforme necessário.

> 📄 **Acesso ao Contrato de Amostra:**  
> Para consultar a minuta utilizada no teste de auditoria (*Contrato Social Consolidado — Nexus Tecnologia Ltda.*), você pode abrir e inspecionar o documento diretamente pelo Cloud Storage:  
> 🔗 **[Visualizar sample_contract.pdf no navegador](https://storage.googleapis.com/workshop-agy-public-assets/sample_contract.pdf)** *(também disponível localmente no seu ambiente em `docs/sample_contract.pdf`)*.

> 📑 **Estrutura Esperada no Relatório de Due Diligence:**  
> O relatório gerado deve conter a identificação da empresa auditada, classificação geral de risco (**ALTO**, **MÉDIO** ou **BAIXO**), matriz de riscos societários (administração, direito de preferência, não concorrência) e parecer conclusivo com recomendações práticas para a Cymbal Technologies.

### Executar e testar a interface ADK Web

1.  💻 **Terminal Cloud Shell (`$`):** No Cloud Shell, certifique-se de estar no diretório do agente e inicie o servidor visual do ADK Web liberando as requisições do proxy reverso:

    ```bash
    cd ~/workshop-agy/due-diligence-agent
    uv run adk web --allow_origins="*"
    ```

2.  🌐 **Navegador (Cloud Shell Web Preview):** Assim que o terminal exibir o banner **`ADK Web Server started | For local testing, access at http://127.0.0.1:8000.`**, basta **clicar diretamente no link `http://127.0.0.1:8000`** exibido no terminal (ou `CTRL+Clique` / `CMD+Clique`) para que o Cloud Shell abra automaticamente a interface do ADK Web em uma nova aba do navegador *(alternativamente, você também pode clicar no botão **Visualização na Web** ![Ícone Web Preview](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/web_preview.png) → **Alterar porta** para **`8000`**; caso a página fique em branco na janela anônima por bloqueio de cookies de terceiros, clique no ícone de olho/escudo na barra de endereços do Chrome e permita cookies para `cloudshell.dev`)*.

3.  🌐 **Chat do ADK Web (Navegador):** No chat da interface web, execute os dois cenários de validação:
   - **Cenário 1 — Teste de Gating Rule:** Envie `Olá, você pode analisar um contrato para mim?`. Valide que o agente responde cordialmente solicitando o envio ou texto do contrato antes de carregar instruções adicionais (*Gating Rule*).
   - **Cenário 2 — Auditoria de Contrato:** Envie o texto do contrato (ou indique o arquivo `docs/sample_contract.pdf`). Valide que o agente carrega as instruções de `references/workflow.md`, analisa cláusulas societárias, administração, quotas e gera o relatório completo de Due Diligence estruturado com classificação de risco e parecer.

4.  🤖 **Prompt do agy (Segunda Aba do Cloud Shell):** **Refinamento e Depuração com agy:** Caso necessite ajustar prompts, reforçar regras de gating ou melhorar a formatação do relatório, clique no ícone **`+`** na barra superior do Cloud Shell para abrir uma nova aba de terminal e inicie o `agy` na raiz do workspace (`~/workshop-agy`):

    ```bash
    cd ~/workshop-agy
    agy
    ```

5.  💻 **Terminal Cloud Shell (`$`):** Quando concluir a validação, retorne à primeira aba do terminal e pressione `CTRL+C` para encerrar o servidor do ADK Web.

---

## Tarefa 4. Fazer o deploy do agente no Google Cloud Agent Runtime

Nesta tarefa, você utiliza o assistente Antigravity CLI para orquestrar a compilação, containerização e implantação do agente no **Google Cloud Agent Runtime** através das skills integradas do `agents-cli`.

> ⏱️ **Tempo Estimado de Deploy:** O provisionamento no Agent Runtime leva de 3 a 7 minutos.  
> 
> ℹ️ **Os Bastidores do Deploy — O que acontece durante a publicação no Agent Runtime:**  
> - **Empacotamento de Contêiner:** O código Python do agente (ADK, regras de skills e dependências do `pyproject.toml`) é empacotado em uma imagem OCI compatível.  
> - **Publicação no Artifact Registry:** A imagem do contêiner é compilada e armazenada no registro privado do seu projeto Google Cloud.  
> - **Provisionamento Serverless:** O Google Cloud instancia o contêiner em infraestrutura serverless gerenciada (baseada no Cloud Run e Vertex AI Agent Engine), com segurança nativa via IAM.  
> - **Geração do Resource Name:** O Vertex AI registra um identificador exclusivo para o seu agente, no formato `projects/.../locations/.../reasoningEngines/...`. Esse identificador é o ponteiro de produção que permitirá ao Gemini Enterprise invocar o agente remotamente; você irá copiá-lo ao final desta tarefa.

### Orquestrar o deployment com o Antigravity CLI

1.  💻 **Terminal Cloud Shell (`$`):** No terminal do Cloud Shell, retorne à raiz do workspace (`~/workshop-agy`, onde estão o arquivo `AGENTS.md` e as skills `.agents/skills/` configuradas) e inicie o `agy`:

    ```bash
    cd ~/workshop-agy
    agy
    ```

2.  🤖 **Prompt do Antigravity CLI (`agy >`):** No prompt do `agy`, solicite a implantação do agente localizado em `./due-diligence-agent` no Agent Runtime. O deploy usará o projeto <ql-variable key="project_0.project_id"></ql-variable> e a região <ql-variable key="project_0.default_region"></ql-variable>, que o próprio assistente descobre a partir da configuração do `gcloud` feita na Tarefa 1:

    ```text
    Faça o deploy do agente localizado na pasta ./due-diligence-agent no Agent Runtime. Use o projeto e a região já configurados neste Cloud Shell, obtendo os valores com "gcloud config get-value project" e "gcloud config get-value compute/region".
    ```

3.  💻 **Terminal Cloud Shell (Segunda Aba):** Enquanto o `agy` aguarda a compilação e o provisionamento na primeira aba, você pode acompanhar o status da operação de longa duração (*Long-Running Operation - LRO*) em uma segunda aba do terminal. No Cloud Shell, clique no ícone **`+`** na barra superior e execute o comando abaixo *(dica: como a compilação ocorre remotamente no Google Cloud, caso sua sessão do Cloud Shell desconecte por inatividade durante os 3 a 7 minutos de espera, basta clicar em **Reconectar** / **Reconnect** e executar este mesmo comando para consultar o progresso e obter o Resource Name)*:

    ```bash
    cd ~/workshop-agy/due-diligence-agent
    agents-cli deploy --status --project $DEVSHELL_PROJECT_ID
    ```

4.  🤖 **Prompt do Antigravity CLI (`agy >`):** Ao término do deployment, retorne à primeira aba e **copie o Resource Name** real do agente implantado exibido pelo `agy` (ou na saída do comando `agents-cli deploy --status`). Guarde esse valor real para colá-lo na Tarefa 5 (nunca digite colchetes como `[PROJECT_ID]` ou `[REGION]`). O Resource Name segue o formato ilustrativo abaixo (não copie este exemplo):

    ```text
    projects/123456789012/locations/us-central1/reasoningEngines/4857320192387645440
    ```

5.  🤖 **Prompt do Antigravity CLI (`agy >`):** Valide a prontidão do agente remoto executando uma consulta de teste diretamente através do `agy`:

    ```text
    Execute um teste rápido contra o agente remoto implantado no Agent Runtime enviando a mensagem "Olá, preciso auditar um contrato social" e confirme se ele responde aplicando a regra de gating.
    ```

6.  🤖 **Prompt do Antigravity CLI (`agy >`):** Quando concluir os testes, saia do assistente digitando `/exit` no prompt do `agy` para retornar ao prompt de comando do Cloud Shell (`$`):

    ```text
    /exit
    ```

---

## Tarefa 5. Conectar e publicar o agente no Gemini Enterprise App

Nesta tarefa final, você conecta o recurso do Agent Runtime ao **Gemini Enterprise App** para disponibilizar o assistente de Due Diligence para os colaboradores corporativos da Cymbal Technologies.

> ⚠️ **Dica de Propagação de IAM no Gemini Enterprise:**  
> Ao vincular o agente e clicar em **Create**, caso a interface exiba uma mensagem temporária de erro de permissão ou falha de comunicação com o runtime, aguarde cerca de 30 a 60 segundos e clique em **Create** novamente. Trata-se do tempo padrão de propagação das permissões do Google Cloud IAM para a conta de serviço interna do Gemini Enterprise (`service-<PROJECT_NUMBER>@gcp-sa-discoveryengine.iam.gserviceaccount.com`) em ambientes recém-provisionados.

### Publicar o agente no Gemini Enterprise

1.  ☁️ **Console Google Cloud:** No Console do Google Cloud, pesquise por **Gemini Enterprise** no campo de pesquisa superior ou navegue pelo **Menu de navegação (☰) > Mais produtos > Inteligência Artificial > Gemini Enterprise** (ou **Agent Builder** / **Discovery Engine**).

2.  ☁️ **Console Google Cloud (Gemini Enterprise):** **Ativação da Licença / Habilitação do GE App:** Se for a primeira vez que você acessa o painel nesta sessão, habilite o Gemini Enterprise App:  
   ![Habilitar Gemini Enterprise App](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_enable.png)

3.  ☁️ **Console Google Cloud (Gemini Enterprise):** **Criar uma Instância do App:** Crie um novo aplicativo corporativo com o nome **Cymbal Compliance & Legal Hub**:  
   ![Criar Instância do GE App](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_create.png)

4.  ☁️ **Console Google Cloud (Gemini Enterprise):** **Adicionar Agente:** No menu lateral do aplicativo, clique em **Agentes** (*Agents*) e selecione **Adicionar Agente** (*Add Agent*):  
   ![Adicionar Agente no GE App](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_add_agent.png)

5.  ☁️ **Console Google Cloud (Gemini Enterprise):** **Selecionar o Tipo de Agente:** Na tela **Choose an agent type**, localize o card **Custom agent via Agent Runtime** e clique em **Add**:  
   ![Selecionar Custom agent via Agent Runtime](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_runtime.png)

6.  ☁️ **Console Google Cloud (Gemini Enterprise):** **Configurar Nome do Agente:** Na etapa **1. Authorizations**, clique em **Skip** (pular). Na etapa **2. Configuration**, preencha o campo **Agent name** com o valor abaixo:

    ```text
    Legal Agent
    ```

7.  ☁️ **Console Google Cloud (Gemini Enterprise):** **Configurar Descrição do Agente:** No campo **Agent description**, cole o texto abaixo:

    ```text
    Revisão de contratos e auditoria de conformidade societária
    ```

8.  ☁️ **Console Google Cloud (Gemini Enterprise):** **Vincular o Resource Name e Criar:** No campo **Agent Runtime reasoning engine**, cole o **Resource Name** real copiado no final da Tarefa 4 (a linha única que começa com `projects/`) e clique em **Create** para vincular o agente ao aplicativo corporativo:  
   ![Configuração do Agente no Gemini Enterprise](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_agent_config.png)

9.  ☁️ **Console Google Cloud (Gemini Enterprise):** **Confirmar Status do Agente:** Após a criação, confirme que o agente aparece listado na tabela de agentes com o status **Enabled**:  
   ![Agente Registrado no Gemini Enterprise](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_agents_table.png)

10. ☁️ **Console Google Cloud (Gemini Enterprise):** **Acessar a Visualização do Aplicativo (Preview):** No menu lateral do aplicativo **Cymbal Compliance & Legal Hub**, clique na aba **Overview** (Visão Geral) e, no card **Preview Gemini Enterprise before customizing**, clique no botão **Preview**:  
   ![Acessar Preview do Gemini Enterprise](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_preview.png)

11. 🌐 **Interface Gemini Enterprise (Preview):** **Selecionar o Agente Corporativo:** Na janela de visualização do aplicativo, acesse o menu lateral **Agents** e, na seção **From your organization**, selecione o agente criado (**Legal Agent**):  
   ![Selecionar Legal Agent no Gemini Enterprise](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_select_agent.png)

12. 🌐 **Chat do Gemini Enterprise App (Produção):** **Executar a Auditoria de Contrato em Produção:** Com o chat do **Legal Agent** aberto, envie o trecho contratual abaixo e valide que o agente invoca o **Agent Runtime** na nuvem, processa os protocolos de Due Diligence estabelecidos na skill e retorna o parecer jurídico estruturado com classificação de risco e recomendações para a Cymbal Technologies:

    ```text
    Por favor, audite a seguinte cláusula do Contrato Social da Nexus Tecnologia Ltda.:
    "A administração da sociedade caberá exclusivamente aos sócios Fulano e Beltrano, sendo necessária a assinatura conjunta para qualquer operação bancária ou alienação de ativos que supere o montante de R$ 50.000,00."
    Qual o parecer e classificação de risco para a Cymbal Technologies?
    ```

---

## Encerrar o Laboratório

1.  Quando você tiver concluído todas as atividades práticas, clique no botão vermelho **Terminar o laboratório** (*End Lab*) no painel superior esquerdo.
2.  Na janela de confirmação, clique em **Enviar** (*Submit*). Todos os recursos provisionados na sua sessão temporária serão desalocados e excluídos com segurança.
3.  Avalie sua experiência com o laboratório selecionando a quantidade de estrelas correspondente:
   - 1 estrela = Muito insatisfeito
   - 2 estrelas = Insatisfeito
   - 3 estrelas = Neutro
   - 4 estrelas = Satisfeito
   - 5 estrelas = Muito satisfeito
4.  Se desejar, deixe um comentário detalhado com seu feedback para ajudar a equipe a aprimorar o treinamento.

---

## Parabéns!

Você concluiu com sucesso o laboratório com desafio de **Implantação de Agente de Due Diligence com Antigravity CLI e ADK**!

Neste laboratório, você:

- Configurou e utilizou o **Antigravity CLI (`agy`)** para acelerar o desenvolvimento de agentes em linha de comando.
- Habilitou e visualizou o catálogo de **Skills** do `agents-cli` integradas ao assistente `agy`.
- Criou um agente inteligente com o **Google ADK** integrado à skill de Due Diligence utilizando o comando `/grill-me`.
- Validou e refinou o comportamento do agente localmente através da interface **ADK Web** com assistência do `agy`.
- Orquestrou o deployment no **Google Cloud Agent Runtime** diretamente através do assistente `agy`.
- Publicou e integrou o agente corporativo no **Gemini Enterprise App** para a **Cymbal Technologies**.

### Treinamento e Certificação do Google Cloud

O programa de [Treinamento do Google Cloud](https://cloud.google.com/training) ajuda você a extrair o máximo das tecnologias de computação em nuvem e inteligência artificial. Nossos cursos incluem habilidades técnicas e melhores práticas para acelerar sua jornada profissional, oferecendo formatos sob demanda, presenciais e virtuais. As [Certificações do Google Cloud](https://cloud.google.com/certification/) validam sua experiência comprovada em arquitetura de nuvem e engenharia de IA.

**Manual Last Updated: September 1, 2026**  
**Lab Last Tested: September 1, 2026**

Copyright 2026 Google LLC. Todos os direitos reservados. Google e o logotipo do Google são marcas registradas da Google LLC. Todos os outros nomes de empresas e produtos podem ser marcas registradas das respectivas empresas com as quais estão associados.
