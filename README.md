# Implantação de um Agente de Due Diligence com Antigravity CLI e ADK: laboratório com desafio

## Informações do Laboratório
* **Tempo estimado:** 1 hora 30 minutos
* **Nível:** `Foundational`

---

## Visão geral

Neste laboratório, você vai demonstrar sua capacidade de usar o **Antigravity CLI (`agy`)** como copiloto de desenvolvimento em terminal para construir um agente inteligente com o **Kit de Desenvolvimento de Agente (ADK)** aproveitando o ecossistema de **Skills** do `agents-cli`. Você vai integrar uma skill especializada de Due Diligence, testar e refinar localmente com a interface **ADK Web**, orquestrar o deploy no **Google Cloud Agent Runtime** diretamente através do `agy` e publicá-lo no **Gemini Enterprise App**.

## Objetivo

Neste laboratório, você vai:

* Configurar e autenticar o Antigravity CLI (`agy`) no ambiente de terminal
* Instalar o `agents-cli` e habilitar a suíte de skills do ADK para uso no `agy`
* Criar e estruturar um agente ADK de Due Diligence integrado a skills usando o comando interativo `/grill-me` no `agy`
* Executar, validar e depurar o fluxo do agente localmente com a interface ADK Web e assistência do `agy`
* Fazer a implantação do agente no Google Cloud Agent Runtime utilizando o `agy` e as skills do `agents-cli`
* Publicar e disponibilizar o agente no Gemini Enterprise App conectando o resource name do Agent Runtime

---

## Configuração e requisitos

### Antes de clicar no botão "Começar o Laboratório"
Leia estas instruções. Os laboratórios são cronometrados e não podem ser pausados. O timer é ativado quando você clica em **Iniciar laboratório** e mostra por quanto tempo os recursos do Google Cloud vão ficar disponíveis.

Este laboratório prático permite que você realize as atividades em um ambiente real de nuvem. Você vai receber credenciais temporárias para fazer login e acessar o Google Cloud e o terminal durante o laboratório.

Confira os requisitos para concluir o laboratório:
* Acesso a um navegador de Internet padrão (recomendamos o Chrome em janela anônima).
* Acesso ao terminal do Cloud Shell ou terminal local autenticado com o Google Cloud SDK (`gcloud`).

### Como iniciar seu laboratório e fazer login no console do Google Cloud
1. Clique no botão **Começar o laboratório**.
2. No painel **Detalhes do Laboratório**, utilize o nome de usuário e senha fornecidos para autenticar no Console do Google Cloud.
3. Aceite os Termos e Condições do ambiente temporário.

---

## Cenário do desafio

A **Cymbal Technologies** é uma empresa líder em soluções corporativas de tecnologia em nuvem e inteligência artificial sediada no Vale do Silício, em franca expansão global. Com uma estratégia agressiva de fusões, aquisições (M&A) e contratação massiva de fornecedores de tecnologia, os times jurídico e de compliance da Cymbal Technologies estão sobrecarregados com o volume de contratos sociais, termos de confidencialidade e instrumentos societários que precisam ser auditados minuciosamente todos os dias.

Para dar escala a essas auditorias mantendo o mais rigoroso padrão de compliance, a liderança de engenharia designou você como Engenheiro de IA da **Cymbal Technologies**. 

**O seu desafio é criar um agente de Due Diligence usando `agents-cli` e ADK para servir no Gemini Enterprise App da Cymbal Technologies através do Agent Runtime.**

Você será responsável por configurar o assistente **Antigravity CLI (`agy`)**, explorar as skills fornecidas pelo `agents-cli`, utilizar técnicas de prompting e refinamento com o comando `/grill-me` para incorporar a skill de auditoria contratual, testar e depurar a solução localmente, orquestrar o deployment no **Agent Runtime** utilizando as skills do `agy` e disponibilizar o agente diretamente no **Gemini Enterprise** para os colaboradores da Cymbal Technologies.

---

## Tarefa 1: Configurar e ativar o Antigravity CLI (`agy`)

O **Antigravity CLI (`agy`)** é o seu assistente de inteligência artificial em linha de comando. Para iniciar a configuração inicial:

1. No terminal, execute o comando de ativação:
   ```bash
   agy
   ```

2. Siga as 4 etapas interativas de autenticação e consentimento exibidas no console:

### Passo 1: Inicialização do setup interativo
![Passo 1 - Inicialização](assets/imgs/agy_auth_1.png)

### Passo 2: Autenticação da conta Google Cloud
![Passo 2 - Autenticação](assets/imgs/agy_auth_2.png)

### Passo 3: Autorização de permissões de acesso
![Passo 3 - Permissões](assets/imgs/agy_auth_3.png)

### Passo 4: Conclusão do setup e ativação do prompt
![Passo 4 - Pronto para Uso](assets/imgs/agy_auth_4.png)

Clique em **Verificar meu progresso** para conferir o objetivo.
*Configurar e ativar o Antigravity CLI.*

---

## Tarefa 2: Instalar o `agents-cli`, habilitar as Skills no `agy` e criar o agente

O `agents-cli` pode ser utilizado de forma autônoma (*standalone*) na linha de comando, mas seu principal diferencial neste fluxo é fornecer um ecossistema completo de **Skills especializadas do Google ADK** diretamente para o Antigravity CLI (`agy`).

1. No terminal, execute a instalação e setup do `agents-cli` utilizando o `uvx`:
   ```bash
   uvx google-agents-cli setup
   ```

   Ao concluir o setup, tanto a CLI quanto as **skills do agents-cli** serão instaladas e configuradas automaticamente no seu ambiente:
   ![Instalação do agents-cli e skills](assets/imgs/agents_cli_install.png)

2. Atualize o `PATH` do ambiente:
   ```bash
   export PATH=$PATH:"/home/${USER}/.local/bin"
   ```

3. Inicie o `agy` e digite o comando `/skills` para verificar as skills do ADK carregadas e disponíveis para o assistente:
   ```bash
   agy
   ```
   > Digite `/skills` no prompt do `agy` para visualizar a lista de skills do `agents-cli` integradas.
   ![Visualização das skills no agy](assets/imgs/agy_agents_cli.png)

4. Crie o arquivo de variáveis de ambiente `.env` com as configurações do seu projeto Google Cloud:
   ```bash
   cat << EOF > .env
   GOOGLE_GENAI_USE_VERTEXAI=TRUE
   GOOGLE_CLOUD_PROJECT=YOUR_GCP_PROJECT_ID
   GOOGLE_CLOUD_LOCATION=us-central1
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

1. Inicie a interface Web do ADK:
   ```bash
   uv run adk web
   ```

2. Acesse a URL fornecida no navegador (por padrão `http://localhost:8000`).

3. Execute os seguintes testes de validação:

| Cenário de Teste | Entrada do Usuário | Comportamento Esperado do Agente |
| :--- | :--- | :--- |
| **Teste de Gating Rule** | `Olá, você pode analisar um contrato para mim?` | O agente responde cordialmente solicitando o envio ou texto do contrato antes de carregar instruções adicionais (*Gating Rule*). |
| **Auditoria de Contrato** | *(Enviar o conteúdo ou arquivo do documento `docs/Contrato Social Consolidado - Nexus Tecnologia Ltda..pdf`)* | O agente carrega as instruções de `references/workflow.md`, analisa cláusulas societárias, administração, quotas e gera o relatório completo de Due Diligence. |

4. **Refinamento e Depuração com `agy`**:
   Após realizar os testes, utilize o `agy` livremente no terminal para investigar comportamentos inesperados, ajustar prompts, corrigir regras de gating ou melhorar a formatação do relatório de auditoria gerado até obter o resultado ideal.

5. Quando concluir os testes, pressione `CTRL+C` no terminal para encerrar o servidor do ADK Web.

Clique em **Verificar meu progresso** para conferir o objetivo.
*Testar, depurar e refinar o agente localmente com ADK Web e Antigravity CLI.*

---

## Tarefa 4: Fazer o deploy do agente no Agent Runtime usando o `agy`

Nesta tarefa, em vez de executar comandos manuais de deploy, você vai solicitar diretamente ao **Antigravity CLI (`agy`)** que utilize suas skills integradas do `agents-cli` (como a skill `google-agents-cli-deploy`) para realizar a implantação do agente no **Google Cloud Agent Runtime**.

1. No terminal, inicie o `agy`:
   ```bash
   agy
   ```

2. Peça ao `agy` para realizar o deployment do agente no Agent Runtime do seu projeto:
   > *"Faça o deploy do agente `due-diligence-agent` no Agent Runtime no projeto `<YOUR_GCP_PROJECT_ID>` na região `us-central1`."*

   > **Observação:** O `agy` utilizará as ferramentas e skills do `agents-cli` para orquestrar a compilação e a implantação no Agent Runtime. Esse processo pode levar de 3 a 7 minutos.

3. Ao término do deployment, anote o **Resource Name** do agente implantado retornado pelo `agy` (formato: `projects/<PROJECT_ID>/locations/<REGION>/agents/<AGENT_ID>`).

4. Valide a prontidão do agente remoto executando uma consulta de teste diretamente com o `agy`.

Clique em **Verificar meu progresso** para conferir o objetivo.
*Implantar o agente no Google Cloud Agent Runtime utilizando o Antigravity CLI.*

---

## Tarefa 5: Conectar e publicar o agente no Gemini Enterprise App

Nesta tarefa final, você disponibilizará o agente de Due Diligence para os colaboradores da Cymbal Technologies dentro do **Gemini Enterprise**.

1. No Console do Google Cloud, acesse o **Gemini Enterprise**.

2. **Ativação da Licença / Habilitação do GE App:** Certifique-se de que o Gemini Enterprise App está habilitado no seu ambiente:
   ![Habilitar Gemini Enterprise App](assets/imgs/ge_app_enable.png)

3. **Criar uma Instância do App:** Crie um novo aplicativo corporativo (por exemplo, `Cymbal Compliance & Legal Hub`):
   ![Criar Instância do GE App](assets/imgs/ge_app_create.png)

4. **Habilitar Recursos de Agentes:**
   * Navegue até a aba **Features** (Recursos) nas configurações do app;
   * Ative a funcionalidade de **Agentes**.

5. **Adicionar Agente:**
   * Retorne para o menu de **Agentes** do aplicativo e clique em **Criar Novo Agente** / **Adicionar Agente**:
   ![Adicionar Agente no GE App](assets/imgs/ge_app_add_agent.png)

6. **Apontar para o Agent Runtime:**
   * Selecione a opção **"Agentes do Agent Runtime"**;
   * Cole o **Resource Name** do agente obtido na Tarefa 4:
   ![Apontar para o Agent Runtime](assets/imgs/ge_app_runtime.png)

7. **Teste de Produção:** Inicie uma conversa com o agente no Gemini Enterprise App, envie um trecho do contrato de teste e valide a geração do relatório de Due Diligence.

Clique em **Verificar meu progresso** para conferir o objetivo.
*Publicar e conectar o agente ao Gemini Enterprise App.*

---

## Parabéns!

Neste laboratório com desafio, você:

- Configurou e utilizou o **Antigravity CLI (`agy`)** para acelerar o desenvolvimento de agentes em terminal;
- Habilitou e visualizou o catálogo de **Skills** do `agents-cli` integradas ao assistente `agy`;
- Criou um agente inteligente com o **Google ADK** integrado à skill de Due Diligence utilizando o comando `/grill-me`;
- Validou e refinou o comportamento do agente localmente através da interface **ADK Web** com assistência do `agy`;
- Orquestrou o deployment no **Google Cloud Agent Runtime** diretamente através do `agy`;
- Publicou e integrou o agente corporativo no **Gemini Enterprise App** para a **Cymbal Technologies**.