# Implantação de um Agente de Due Diligence com Antigravity CLI e ADK: Laboratório com Desafio

## Informações do Laboratório

- **Tempo estimado:** 1 hora 30 minutos
- **Nível:** `Foundational` / `Intermediate`

---

## Visão Geral

Neste laboratório prático com desafio, você vai demonstrar sua capacidade de usar o **Antigravity CLI (`agy`)** como copiloto de desenvolvimento em terminal para construir um agente inteligente com o **Kit de Desenvolvimento de Agente (ADK)** aproveitando o ecossistema de **Skills** do `agents-cli`.

Você vai integrar uma skill especializada de Due Diligence, testar e refinar o comportamento localmente com a interface **ADK Web**, orquestrar a implantação no **Google Cloud Agent Runtime** diretamente através do assistente `agy` e publicá-lo no **Gemini Enterprise App**.

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

1. No painel lateral esquerdo do laboratório, clique com o botão direito no botão **Abrir console do Google Cloud** e selecione **Abrir link em janela anônima**.

2. Na tela de login do Google, cole o **Nome de usuário** temporário (<ql-variable key="user_0.username"></ql-variable>) e clique em **Avançar**.

3. Cole a **Senha** temporária fornecida no painel e clique em **Avançar**.

4. Conclua as telas seguintes:
   - Aceite os Termos e Condições do serviço;
   - **NÃO** adicione opções de recuperação ou autenticação em duas etapas (2FA) nesta conta temporária;
   - **NÃO** se inscreva para períodos de teste gratuito.

Após alguns instantes, o Console do Google Cloud será aberto nesta aba anônima.

> ℹ️ **Aviso sobre Respostas e Quotas de Modelos:**  
> Para garantir uma experiência consistente, de alto desempenho e evitar esgotamento de cotas de API (`429 RESOURCE_EXHAUSTED`) durante a execução em turmas com múltiplos alunos simultâneos, este laboratório inclui mecanismos de contingência e respostas pré-armazenadas para garantir a continuidade das atividades.

---

## Cenário do Desafio

A **Cymbal Technologies** é uma empresa líder em soluções corporativas de tecnologia em nuvem e inteligência artificial sediada no Vale do Silício, em franca expansão global. Com uma estratégia agressiva de fusões, aquisições (M&A) e contratação massiva de fornecedores de tecnologia, os times jurídico e de compliance da Cymbal Technologies estão sobrecarregados com o volume de contratos sociais, termos de confidencialidade e instrumentos societários que precisam ser auditados minuciosamente todos os dias.

Para dar escala a essas auditorias mantendo o mais rigoroso padrão de compliance, a liderança de engenharia designou você como Engenheiro de IA da **Cymbal Technologies**. 

**O seu desafio é criar um agente de Due Diligence usando `agents-cli` e ADK para servir no Gemini Enterprise App da Cymbal Technologies através do Agent Runtime.**

Você será responsável por configurar o assistente **Antigravity CLI (`agy`)**, explorar as skills fornecidas pelo `agents-cli`, utilizar técnicas de prompting e refinamento com o comando `/grill-me` para incorporar a skill de auditoria contratual, testar e depurar a solução localmente, orquestrar o deployment no **Agent Runtime** utilizando as skills do `agy` e disponibilizar o agente diretamente no **Gemini Enterprise** para os colaboradores da Cymbal Technologies.

---

## Tarefa 1. Configurar o ambiente e inicializar o Antigravity CLI

Nesta tarefa, você inicializa as variáveis do Cloud Shell, clona os artefatos do workshop, instala as ferramentas CLI (`uv` e `agy`) e autentica o assistente de desenvolvimento no seu projeto Google Cloud.

### Ativar o Cloud Shell e inicializar variáveis

1. No canto superior direito do Console do Google Cloud, clique no botão **Ativar o Cloud Shell** (ícone `>_`).

2. Se solicitado, clique em **Continuar** na janela informativa de provisionamento do Cloud Shell.

3. Inicialize as variáveis de ambiente com o projeto sandbox ativo e a região atribuída executando o bloco abaixo:

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

echo "=========================================="
echo "Projeto Sandbox Ativo: ${PROJECT_ID}"
echo "Região Ativa:          ${REGION}"
echo "Zona Ativa:            ${ZONE}"
echo "=========================================="
```

4. Quando for exibida a janela pop-up solicitando **"Autorizar o Cloud Shell a fazer chamadas de API do GCP"** (*Authorize Cloud Shell to make GCP API calls*), clique obrigatoriamente em **Autorizar** (*Authorize*).

5. Clone o repositório do workshop para obter o contrato de amostra e a skill de Due Diligence:

```bash
git clone https://github.com/carlosmscabral/workshop-agy.git ~/workshop-agy
cd ~/workshop-agy
```

### Instalar ferramentas e autenticar o Antigravity CLI

1. Instale o gerenciador de pacotes moderno `uv`:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
```

2. Instale a ferramenta de linha de comando do Antigravity (`agy`):

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
export PATH="$HOME/.local/bin:$PATH"
```

3. Inicie o setup interativo do **Antigravity CLI**:

```bash
agy
```

4. Siga as 9 etapas de autenticação, configuração e inicialização exibidas no terminal:

- **Passo 1:** Selecione a opção **`2. Use a Google Cloud project`**:  
  ![Passo 1 - Inicialização](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_1.png)

- **Passo 2:** Selecione a opção **`1. Continue with Google Cloud`**:  
  ![Passo 2 - Autenticação](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_2.png)

- **Passo 3:** Abra o link de autorização exibido no terminal em uma nova aba da sua Janela Anônima, selecione a conta de estudante <ql-variable key="user_0.username"></ql-variable> e conceda o consentimento:  
  ![Passo 3 - Permissões](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_auth_3.png)

- **Passo 4:** Cole o ID do seu projeto sandbox (<ql-variable key="project_0.project_id"></ql-variable>) no prompt e confirme pressionando `ENTER`:  
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

---

## Tarefa 2. Instalar o agents-cli, habilitar skills e criar o agente

Nesta tarefa, você instala o `agents-cli`, habilita o catálogo de skills do ADK no assistente `agy`, configura as variáveis de ambiente do projeto e utiliza o comando `/grill-me` para alinhar e gerar a arquitetura do agente de Due Diligence.

> ℹ️ **Atenção — Retornar ao terminal bash (sair do `agy`):**  
> Ao concluir o setup interativo na Tarefa 1, o assistente `agy` é iniciado automaticamente e permanece ativo no seu terminal. Para executar os comandos de instalação e ambiente a seguir (`uvx`, `export`, `.env`), certifique-se de sair do assistente digitando `/exit` e pressionando `ENTER` para retornar ao prompt de comando do Cloud Shell (`$`).

### Habilitar skills e configurar ambiente

1. No terminal do Cloud Shell (fora do `agy`), instale e configure o `agents-cli` utilizando o `uvx`:

```bash
uvx google-agents-cli setup
```

Ao concluir o setup, tanto a CLI quanto as **skills do agents-cli** estarão instaladas e vinculadas automaticamente:
![Instalação do agents-cli e skills](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agents_cli_install.png)

2. Atualize o `PATH` da sessão atual:

```bash
export PATH=$PATH:"$HOME/.local/bin"
```

3. Inicie o `agy` e digite `/skills` para verificar o catálogo de skills do ADK integradas ao assistente:

```bash
agy
```

> Digite `/skills` no prompt do `agy` para visualizar a lista de skills do `agents-cli` integradas. Pressione `ESC` para fechar o menu de skills e digite `/exit` para retornar ao bash.
![Visualização das skills no agy](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_agents_cli.png)

4. Crie o arquivo de configuração `.env` contendo os parâmetros dinâmicos do seu projeto Google Cloud:

```bash
cat << EOF > .env
GOOGLE_GENAI_USE_VERTEXAI=TRUE
GOOGLE_CLOUD_PROJECT=${PROJECT_ID}
GOOGLE_CLOUD_LOCATION=${REGION}
MODEL=gemini-2.5-flash
EOF
```

### Alinhar e estruturar o agente com o comando /grill-me

1. Inicie o `agy`:

```bash
agy
```

2. No prompt do `agy`, execute o comando `/grill-me` para iniciar a entrevista interativa de alinhamento arquitetural do agente:

```
/grill-me
```

> 📋 **Guia de Alinhamento Interativo (`/grill-me`):**
> 
> Durante a execução do `/grill-me`, o assistente formulará perguntas de arquitetura. Utilize as respostas recomendadas abaixo baseadas na skill em `skills/due-diligence-contract/SKILL.md`:
> 
> | Pergunta do Assistente | Resposta Sugerida |
> | :--- | :--- |
> | **Qual é o objetivo central do agente?** | *Auditar contratos sociais e minutas societárias para identificar riscos jurídicos, cláusulas de administração e restrições de quotas.* |
> | **Quais ferramentas ou skills devem ser integradas?** | *Utilizar a skill em `skills/due-diligence-contract` e os templates oficiais do `agents-cli`.* |
> | **Qual é a regra de gating de entrada?** | *O agente só deve carregar o checklist detalhado após receber um contrato ou texto jurídico válido do usuário.* |
> | **Qual é o formato de saída esperado?** | *Relatório estruturado em Markdown com classificação de risco (Alto/Médio/Baixo) e recomendações práticas.* |

3. Concluído o alinhamento com o `/grill-me`, instrua o `agy` a gerar o projeto do agente:

> *"Crie um projeto de agente ADK chamado `due-diligence-agent` utilizando as skills do `agents-cli` e integre os protocolos e regras da skill em `skills/due-diligence-contract`."*

4. **Configurar Modo Permissivo de Ferramentas (`always-proceed`):**  
   Para permitir que o assistente orquestre comandos e deployments com maior autonomia nas próximas tarefas (sem solicitar confirmação manual para cada ação executada no terminal):
   - No prompt do `agy`, digite `/config` para abrir o menu de preferências;
   - Navegue com as setas do teclado até a opção **Tool Permission**;
   - Alterne o valor para **`always-proceed`** e confirme com `ENTER`;
   - Pressione `ESC` para fechar o menu de configurações.

   ![Configuração de Permissão de Ferramentas no agy](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/agy_config_tool_permission.png)

5. Saia do `agy` digitando `/exit` e sincronize as dependências do agente gerado:

```bash
cd ~/workshop-agy
uv sync
```

---

## Tarefa 3. Testar e refinar o agente localmente com ADK Web

Nesta tarefa, você valida o comportamento do agente e suas regras de gating através da interface visual do ADK Web, utilizando o `agy` para depurar e refinar qualquer resposta conforme necessário.

### Executar e testar a interface ADK Web

1. No Cloud Shell, inicie o servidor visual do ADK Web liberando as requisições do proxy reverso:

```bash
uv run adk web --allow_origins="*"
```

> 💡 **Nota sobre o Web Preview:** A flag `--allow_origins="*"` é necessária para que o servidor ASGI local do ADK permita requisições originadas do proxy reverso de visualização na web do Cloud Shell (`*.cloudshell.dev`). Mantenha as aspas duplas no comando para evitar que o shell execute expansão de curinga (*globbing*) com arquivos do diretório.

2. No canto superior direito do Cloud Shell, clique no botão **Visualização na Web** (*Web Preview*) e selecione **Visualizar na porta 8000** (*Preview on port 8000*).

3. Execute os seguintes cenários de validação no chat da interface web:

| Cenário de Teste | Entrada do Usuário | Comportamento Esperado do Agente |
| :--- | :--- | :--- |
| **Teste de Gating Rule** | `Olá, você pode analisar um contrato para mim?` | O agente responde cordialmente solicitando o envio ou texto do contrato antes de carregar instruções adicionais (*Gating Rule*). |
| **Auditoria de Contrato** | *(Enviar o conteúdo ou indicar o documento `docs/sample_contract.pdf`)* | O agente carrega as instruções de `references/workflow.md`, analisa cláusulas societárias, administração, quotas e gera o relatório completo de Due Diligence. |

> 📑 **Exemplo de Formatação Esperada no Relatório de Due Diligence:**

```markdown
### Relatório de Due Diligence Contratual — Nexus Tecnologia Ltda.

- **Empresa Auditada:** Nexus Tecnologia Ltda.
- **Classificação Geral de Risco:** MÉDIO

#### 1. Matriz de Riscos e Cláusulas Críticas

- **Cláusula de Administração (Cláusula 5ª):** Exige assinatura conjunta para obrigações superiores a R$ 50.000,00. *Risco Médio de Governança*.
- **Direito de Preferência (Cláusula 8ª):** Prazo estrito de 30 dias para exercício de preferência entre sócios. *Conforme*.
- **Não Concorrência (Cláusula 12ª):** Restrição de 24 meses em território nacional. *Atenção aos limites geográficos*.

#### 2. Parecer e Recomendações
Recomenda-se colher anuência expressa de ambos os sócios administradores em caso de celebração de contratos de vulto com a Cymbal Technologies.
```

4. **Refinamento e Depuração com `agy`:**  
   Caso necessite ajustar prompts, reforçar regras de gating ou melhorar a formatação do relatório, abra uma segunda aba de terminal e utilize o `agy` livremente para refinar os arquivos do agente.

5. Quando concluir a validação, pressione `CTRL+C` no terminal para encerrar o servidor do ADK Web.

---

## Tarefa 4. Fazer o deploy do agente no Google Cloud Agent Runtime

Nesta tarefa, você utiliza o assistente Antigravity CLI para orquestrar a compilação, containerização e implantação do agente no **Google Cloud Agent Runtime** através das skills integradas do `agents-cli`.

### Orquestrar o deployment com o Antigravity CLI

1. No terminal do Cloud Shell, inicie o `agy`:

```bash
agy
```

2. Peça ao `agy` para realizar o deployment do agente no Agent Runtime do seu projeto sandbox:

> *"Faça o deploy do agente due-diligence-agent no Agent Runtime no projeto <ql-variable key="project_0.project_id"></ql-variable> na região <ql-variable key="project_0.default_region"></ql-variable>."*

> ⏱️ **Tempo Estimado:** O `agy` utilizará as ferramentas da skill `google-agents-cli-deploy` para orquestrar a compilação de container e provisionamento no Agent Runtime. Este processo leva de 3 a 7 minutos.

3. Ao término do deployment, anote o **Resource Name** do agente implantado retornado pelo `agy` (formato canônico: `projects/[PROJECT_ID]/locations/[REGION]/agents/[AGENT_ID]`).

4. Valide a prontidão do agente remoto executando uma consulta de teste diretamente através do `agy`.

5. Quando concluir os testes, saia do assistente digitando `/exit` no prompt do `agy`.

---

## Tarefa 5. Conectar e publicar o agente no Gemini Enterprise App

Nesta tarefa final, você conecta o recurso do Agent Runtime ao **Gemini Enterprise App** para disponibilizar o assistente de Due Diligence para os colaboradores corporativos da Cymbal Technologies.

### Publicar o agente no Gemini Enterprise

1. No Console do Google Cloud, pesquise por **Gemini Enterprise** no campo de pesquisa superior ou acesse **Agent Builder** / **Discovery Engine**.

2. **Ativação da Licença / Habilitação do GE App:** Se for a primeira vez que você acessa o painel nesta sessão, habilite o Gemini Enterprise App:  
   ![Habilitar Gemini Enterprise App](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_enable.png)

3. **Criar uma Instância do App:** Crie um novo aplicativo corporativo com o nome **Cymbal Compliance & Legal Hub**:  
   ![Criar Instância do GE App](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_create.png)

4. **Habilitar Recursos de Agentes:**
   - No menu lateral do aplicativo, clique na aba **Features** (Recursos);
   - Ative a opção **Agentes** (*Agents*).

5. **Adicionar Agente:**
   - No menu lateral do aplicativo, clique em **Agentes** (*Agents*) e selecione **Adicionar Agente** (*Add Agent*):  
   ![Adicionar Agente no GE App](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_add_agent.png)

6. **Apontar para o Agent Runtime:**
   - Selecione a opção **"Agentes do Agent Runtime"** (*Agent Runtime agents*);
   - No campo correspondente, cole o **Resource Name** do agente obtido na Tarefa 4:  
   ![Apontar para o Agent Runtime](https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/ge_app_runtime.png)

7. **Teste de Produção:** Inicie uma conversa com o agente no Gemini Enterprise App, envie um trecho do contrato de teste e valide a geração do relatório de Due Diligence em ambiente corporativo.

---

## Encerrar o Laboratório

1. Quando você tiver concluído todas as atividades práticas, clique no botão vermelho **Terminar o laboratório** (*End Lab*) no painel superior esquerdo.
2. Na janela de confirmação, clique em **Enviar** (*Submit*). Todos os recursos provisionados na sua sessão temporária serão desalocados e excluídos com segurança.
3. Avalie sua experiência com o laboratório selecionando a quantidade de estrelas correspondente:
   - 1 estrela = Muito insatisfeito
   - 2 estrelas = Insatisfeito
   - 3 estrelas = Neutro
   - 4 estrelas = Satisfeito
   - 5 estrelas = Muito satisfeito
4. Se desejar, deixe um comentário detalhado com seu feedback para ajudar a equipe a aprimorar o treinamento.

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
