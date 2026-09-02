# Ideias de Melhorias e Padronização: workshop-agy à luz do CloudVLab

Este documento sintetiza uma análise aprofundada do repositório oficial de laboratórios do Google Cloud (**`CloudVLab/gcp-spl-content`**) e apresenta um catálogo prático de propostas de melhorias e padronizações para o projeto **`workshop-agy`** (*Laboratório de Due Diligence com Antigravity CLI e ADK*).

---

## 1. O Contraste dos Dois Modelos de Execução

Antes de propor qualquer modificação técnica ou textual, é mandatório reconhecer a distinção arquitetural entre a esteira formal do Google e o nosso modelo de workshop:

```
+---------------------------------------------------------------------------------------------------+
| MODELO A: Esteira Formal de Publicação SPL (CloudVLab / Alexandria CI/CD)                         |
| • Repositório centralizado (github.com/CloudVLab/gcp-spl-content) com 50.000+ arquivos.          |
| • Compilação prévia pelo compilador proprietário Alexandria.                                      |
| • Suporte nativo a macros: transclusão (![[/fragments/...]]), <ql-code-block templated>,          |
|   interpolação {{{project_0.project_id}}}, e validação com scripts Ruby (handles['...']).         |
| • Atualizações de código disparam pipelines automatizados de teste, validação de branch e PRs.    |
+---------------------------------------------------------------------------------------------------+
                                              VS
+---------------------------------------------------------------------------------------------------+
| MODELO B: Laboratório Privado com Deploy Manual (workshop-agy em explore.qwiklabs.com)           |
| • Instruções coladas manualmente no Web Editor (Markdown executado via JavaScript no navegador).  |
| • Automação de infraestrutura empacotada via Archive.zip e enviada manualmente para o project_0.  |
| • Parser client-side: SimpleMDE / marked.js (NÃO interpreta macros Alexandria).                  |
| • Requer estritamente cercas GFM puras (```bash```), variáveis $DEVSHELL_PROJECT_ID no terminal    |
|   e tags registradas como Web Components nativos (<ql-variable key="...">).                       |
+---------------------------------------------------------------------------------------------------+
```

> [!IMPORTANT]
> **Premissa de Ouro:** As configurações atuais do `workshop-agy` **estão plenamente funcionais**. 
> O objetivo desta análise não é quebrar o modelo operacional do deploy manual tentando emular macros incompatíveis da Alexandria, mas sim **incorporar as melhores práticas editoriais, pedagógicas, de resiliência e de experiência do aluno (UX)** que o time de Lab Architects do Google Cloud consolidou.

---

## 2. Matriz Comparativa: O que Importar vs. O que Manter

| Recurso / Componente | Padrão Formal CloudVLab (Alexandria) | Como Opera no Deploy Manual (`explore`) | Diretriz para o `workshop-agy` |
| :--- | :--- | :--- | :--- |
| **Blocos de Código** | `<ql-code-block language="bash" templated>` com `{{{...}}}` | Quebra no navegador (converte `"` em `&quot;`, achata quebras de linha e não interpola variáveis) | **MANTER:** Cercas GFM puras (```` ```bash ````) usando variáveis de ambiente (`$DEVSHELL_PROJECT_ID`, `${REGION}`). |
| **Variáveis no Texto** | `<ql-variable key="project_0.project_id">` ou `{{{...}}}` | `<ql-variable key="...">` é um Web Component nativo que funciona no browser | **PADRONIZAR:** Usar `<ql-variable>` no corpo do texto; lembrar sempre que o atributo é `default_region`, nunca `region`. |
| **Caixas de Alerta** | `<ql-infobox>` e `<ql-warningbox>` | Suportados como HTML ou via GFM Blockquotes (`> ⚠️`) | **PADRONIZAR:** Padronizar o design dos callouts para coincidir com a identidade visual do Google Cloud. |
| **Fragmentos / Reuso** | `![[/fragments/gcpconsole]]` | Não expande; renderiza texto literal quebrado no navegador | **MANTER:** Seções essenciais escritas de forma inline e autossuficiente no Markdown. |
| **Avaliação do Aluno** | Scripts Ruby (`assessments/*.rb`) lendo buckets GCS e avaliando com Gemini | Depende de configuração manual de Activity Tracking na UI do Qwiklabs | **INOVAR:** Criar um script de autoverificação CLI no Cloud Shell (`verify.sh`) e preparar os arquivos de resumo (`summary.md`). |
| **Resiliência a Quota** | `Graceful429Plugin` no ADK para interceptar `RESOURCE_EXHAUSTED` | Falhas de quota travam o terminal do aluno durante workshops lotados | **IMPORTAR:** Implementar plugin de fallback gracioso de 429 no template do agente. |

---

## 3. Catálogo de Ideias de Melhorias

### Eixo 1: Padronização Editorial & Estilo Instrucional (CLS Writing Style Guide)
O documento `.gemini/styleguide.md` do CloudVLab define os padrões formais de redação de labs do Google Cloud Learning Services (CLS). Podemos aplicar imediatamente:

1. **Padronização dos Títulos de Tarefas (Imperative Sentence Case, No Ending Punctuation):**
   - *Como está hoje:* `## Tarefa 1: Configuração do Ambiente e Inicialização do Antigravity CLI (agy)`
   - *Padrão CLS:* `## Tarefa 1. Configurar o ambiente e inicializar o Antigravity CLI`
   - *Regra:* Usar `Tarefa N. [Verbo no Imperativo]`, sem dois pontos e sem ponto final no título.

2. **Task Summaries Obrigatórios (1 a 2 frases no presente simples):**
   - No padrão oficial, imediatamente após o título da tarefa, há um resumo claro e conciso da ação antes de iniciar os passos, por exemplo:
     > *"Nesta tarefa, você inicializa as variáveis do Cloud Shell, instala as ferramentas CLI (`uv` e `agy`) e autentica o assistente de desenvolvimento no seu projeto Google Cloud."*

3. **Subtarefas Não Numeradas com Verbo no Imperativo:**
   - Em vez de passos soltos ou subtítulos descritivos passivos, usar subtarefas com verbos de ação:
     * `### Inicializar o Cloud Shell e variáveis`
     * `### Clonar o repositório do workshop`
     * `### Instalar e autenticar o Antigravity CLI`

4. **Regra de Ouro da CLS: Ação Única por Passo Numerado (*Single Action per Step*):**
   - *Problema atual:* No passo 5 da Tarefa 1, o lab instala `uv`, carrega o ambiente, instala `agy` e atualiza o `PATH` em um único bloco.
   - *Padrão CLS:* Cada passo numerado deve representar uma ação atômica e compreensível para o aluno e para leitores de tela:
     * Passo 5: Instale o gerenciador de pacotes `uv`.
     * Passo 6: Instale a ferramenta de linha de comando `agy`.
     * Passo 7: Inicie o assistente executando o comando `agy`.

5. **Elementos de Interface em Negrito com o Rótulo Precedendo a Ação:**
   - No padrão Google: o rótulo do botão ou menu deve ser especificado antes da ação.
   - *Exemplo:* "No campo **ID do Projeto**, cole o valor..." ou "No canto superior direito, clique em **Cloud Shell**."

6. **Tratamento Direto Exclusivo na 2ª Pessoa ("Você") e Eliminação da 1ª Pessoa do Plural:**
   - Eliminar termos como *"vamos fazer"*, *"clonamos o repositório"*, *"nosso agente"*.
   - Usar consistentemente: *"você faz"*, *"configure o agente"*, *"seu projeto"*.

7. **Metadados Canônicos de Rodapé:**
   - Incluir ao final das instruções os carimbos oficiais de governança:
     ```markdown
     **Manual Last Updated: September 1, 2026**
     **Lab Last Tested: September 1, 2026**
     ```

---

### Eixo 2: Resiliência Técnica contra Quotas & Erros 429 (`Graceful429Plugin`)
No CloudVLab, a skill `.agent/skills/add-adk-429-error-handling/SKILL.md` trata de uma das maiores dores de cabeça em treinamentos presenciais e workshops de GenAI: **estouro de quota de API (`429 Quota Exceeded / RESOURCE_EXHAUSTED`) quando 30 a 100 alunos chamam o Gemini simultaneamente**.

#### A Solução Oficial do Google:
O CloudVLab desenvolveu um plugin modular para o ADK (`Graceful429Plugin`) que intercepta exceções `429` ou `503` durante chamadas síncronas e assíncronas do modelo, devolvendo uma resposta realista pré-armazenada baseada em palavras-chave do prompt.

#### Como Aplicar no `workshop-agy`:
1. Incluir no repositório um módulo utilitário leve `workshop_utils/plugins.py` contendo o `Graceful429Plugin`.
2. Ao criar ou orientar a criação do agente com ADK, plugar o interceptor de 429.
3. Se um aluno atingir o limite de requisições por minuto (RPM) durante a sessão, o agente não entra em pânico nem crasha o terminal; ele devolve o relatório de Due Diligence mockado e exibe um aviso amigável:
   ```
   [Aviso de Quota]: Limite temporário da API atingido. Exibindo resposta simulada de auditoria para prosseguir com o laboratório.
   ```
Isso garante 100% de taxa de sucesso e evita que alunos fiquem bloqueados em salas de aula.

---

### Eixo 3: Estratégia de Autoverificação e Feedback do Aluno (*Self-Check CLI*)
Nos labs oficiais como o `gsp1398-get-started-with-antigravity`:
- O aluno solicita ao agente que gere um arquivo `summary_task1.md` (com ID do projeto e e-mail).
- O arquivo é enviado para `gs://${PROJECT_ID}-grading/`.
- Um script Ruby (`check_task1_setup.rb`) no backend Qwiklabs lê o arquivo e chama o Gemini para pontuar o aluno.

#### Proposta Adaptada para o `workshop-agy`:
Como o nosso deploy manual pode ser executado sem o motor de grading do Qwiklabs configurado na plataforma, podemos oferecer uma **experiência híbrida superior**:

1. **Script de Autoverificação no Cloud Shell (`./scripts/check_progress.sh`):**
   Disponibilizar no repositório um script interativo de autoverificação que o aluno pode rodar a qualquer momento:
   ```bash
   ./scripts/check_progress.sh --task 1
   ```
   O script verifica:
   - Se `agy` está instalado e autenticado (`~/.gemini` ou token ativo);
   - Se o `.env` contém as variáveis corretas (`GOOGLE_CLOUD_PROJECT`, `GOOGLE_CLOUD_LOCATION`);
   - Se o agente responde localmente;
   - Se as portas locais (8000/8080) estão ouvindo conexões.
   Retorna um relatório visual colorido no terminal com `[OK]` verde ou `[FAIL]` com dicas claras de correção.

2. **Preparação para o Padrão GCS Grading:**
   Manter a instrução para o `agy` gerar `summary_task1.md` e `summary_task2.md`. Caso a organização decida no futuro cadastrar os passos de Activity Tracking na interface do Qwiklabs, as instruções do aluno já estarão 100% prontas e compatíveis!

---

### Eixo 4: Otimização do Startup Script & Pre-Warming
Atualmente, nosso script de provisionamento (`terraform/scripts/script.sh` executado pelo Project Octopus durante a inicialização de 1-2 minutos do laboratório) já habilita as APIs e define o metadata de região.

Podemos expandi-lo com melhorias de baixo risco e alto retorno:
1. **Criação do Bucket de Apoio/Grading:**
   Adicionar no `script.sh`:
   ```bash
   # Criar bucket de apoio do laboratório se não existir
   gcloud storage buckets create "gs://${PROJECT_ID}-workshop" --location="${REGION}" --uniform-bucket-level-access || true
   ```
2. **Pre-Warming de Imagens de Container do Agent Runtime / Cloud Run:**
   Se o deployment do Agent Runtime envolve imagens base, podemos disparar um pull inicial no script headless, reduzindo o tempo de espera do aluno na Tarefa 4 de 7 minutos para 2 a 3 minutos.
3. **Criação de Arquivo de Diagnóstico (`/etc/lab-ready`):**
   Ao final do `script.sh`, criar um arquivo de status para que scripts de validação saibam com precisão se a infraestrutura concluiu o provisionamento.

---

### Eixo 5: Hardening de Segurança e Least Privilege (Padrões do `harden-lab`)
A skill `.agent/skills/harden-lab/SKILL.md` do CloudVLab adverte enfaticamente contra conceder `roles/owner` ou `roles/editor` aos alunos temporários em sandboxes do Qwiklabs.

#### Recomendações para a Configuração do Recurso no `explore.qwiklabs.com`:
Ao configurar as permissões do usuário aluno (`user_0`) no painel de recursos do laboratório, mapear a lista de privilégios mínimos recomendada para agentes GenAI:
- `roles/viewer` (visualização básica do projeto)
- `roles/aiplatform.user` (inferência de modelos Gemini e Vertex AI Agent Engine)
- `roles/discoveryengine.admin` (gerenciamento do Gemini Enterprise App / Intranet Search)
- `roles/storage.admin` (acesso a buckets de contratos e staging do Agent Runtime)
- `roles/run.developer` e `roles/run.invoker` (execução de contêineres do runtime)
- `roles/serviceusage.serviceUsageConsumer` (obrigatório para que comandos de CLI consultem cotas de serviço sem erro)

---

### Eixo 6: Melhorias de Experiência e Storytelling no `lab_instructions.md`
Inspirando-se no `gsp1398`:
1. **Tabela de Atalhos do Antigravity CLI:**
   Adicionar uma tabela rápida de comandos úteis do `agy` logo na Tarefa 1 (ex.: atalhos de terminal, `/help`, `/skills`, `/grill-me`, `/clear`).
2. **Guia de Respostas para o `/grill-me`:**
   O comando `/grill-me` faz perguntas investigativas. Para evitar que alunos menos experientes fiquem confusos sem saber o que responder, incluir nas instruções uma tabela com **Perguntas Típicas do Assistente vs. Respostas Recomendadas**.
3. **Exemplo Visual do Relatório de Due Diligence:**
   Incluir nas instruções um bloco de exemplo com a formatação Markdown esperada do relatório final gerado pelo agente (com checklist de compliance, matriz de risco alto/médio/baixo e recomendações jurídicas).

---

---

## 4. Catálogo de Blurbs Canônicos e Recomendações Comuns (Prontos para Cópia Manual)

Como o nosso modelo utiliza **deploy manual** no Web Editor do `explore.qwiklabs.com`, **não podemos utilizar transclusão de macros Alexandria (`![[/fragments/...]]`)**. No entanto, podemos copiar e adaptar o texto exato desses componentes canônicos.

Abaixo está o acervo dos blurbs mais utilizados nos laboratórios oficiais do Google Cloud, já traduzidos e adaptados para o formato **Pure GFM** com `<ql-variable>`:

---

### Blurb 1: Recomendações Antes de Iniciar (Janela Anônima e Contas)
*Origem: `fragments/startqwiklab/en.md` e `pt_BR.html`*

```markdown
### Antes de clicar no botão Iniciar laboratório

Leia atentamente estas instruções. Os laboratórios são cronometrados e não podem ser pausados. O temporizador é iniciado assim que você clica em **Iniciar laboratório** e indica por quanto tempo os recursos do Google Cloud permanecerão disponíveis para você.

Este laboratório prático permite realizar as atividades em um ambiente real de nuvem, e não em uma simulação ou demonstração. Você receberá novas credenciais temporárias para fazer login e acessar o Google Cloud durante a sessão.

Para concluir este laboratório, você precisa de:

- Acesso a um navegador de internet padrão (recomendamos o Google Chrome).
- Tempo suficiente para concluir o roteiro — lembre-se de que não é possível pausar um laboratório em andamento.

> ⚠️ **MUITO IMPORTANTE — Janela Anônima Obrigatória:**  
> Utilize sempre uma **Janela Anônima (Incognito)** ou privada do navegador para executar este laboratório. Isso evita conflitos de autenticação entre sua conta pessoal/corporativa e a conta de estudante temporária, prevenindo cobranças indevidas em sua conta pessoal.

> 🔒 **Uso Exclusivo da Conta de Estudante:**  
> Utilize estritamente as credenciais fornecidas no painel do laboratório. Se você utilizar sua conta pessoal do Google Cloud, cobranças poderão ser geradas diretamente nela.
```

---

### Blurb 2: Login no Console do Google Cloud
*Origem: `fragments/gcpconsole/en.md` e `pt_BR.html`*

```markdown
### Fazer login no Console do Google Cloud

1. Clique no botão **Abrir console do Google Cloud** no painel lateral esquerdo (ou clique com o botão direito e selecione **Abrir link em janela anônima** se estiver usando o Chrome).

   O painel **Configuração e acesso ao laboratório** disponibiliza:
   - O botão para abrir o console;
   - O **Nome de usuário** temporário (`<ql-variable key="user_0.username"></ql-variable>`);
   - A **Senha** temporária;
   - O **ID do projeto** atribuído (`<ql-variable key="project_0.project_id"></ql-variable>`).

2. Se a página solicitar a seleção de conta, clique em **Usar outra conta**.

3. No campo **E-mail ou telefone**, cole o **Nome de usuário** fornecido pelo painel e clique em **Avançar**.

4. No campo **Digite sua senha**, cole a **Senha** temporária fornecida e clique em **Avançar**.

5. Conclua as telas de boas-vindas seguintes:
   - Aceite os Termos e Condições do serviço;
   - **NÃO** adicione opções de recuperação ou autenticação em duas etapas (2FA) nesta conta temporária;
   - **NÃO** se inscreva para períodos de teste gratuito.

Após alguns instantes, o Console do Google Cloud será aberto no navegador.

> 💡 **Dica de Navegação:** Para acessar os serviços e produtos do Google Cloud, clique no **Menu de navegação** (ícone de três linhas horizontais no canto superior esquerdo) ou digite o nome do recurso no campo de pesquisa superior.
```

---

### Blurb 3: Ativação e Autorização do Cloud Shell
*Origem: `fragments/cloudshell/en.md` e `pt_BR.html`*

```markdown
### Ativar o Cloud Shell

O Cloud Shell é uma máquina virtual equipada com ferramentas essenciais de desenvolvimento e administração de nuvem. Ele oferece um diretório inicial persistente de 5 GB e opera diretamente no Google Cloud, fornecendo acesso de linha de comando aos recursos do seu projeto.

1. No canto superior direito do Console do Google Cloud, clique no botão **Ativar o Cloud Shell** (ícone de terminal `>_`).

2. Na primeira inicialização, avance pelas janelas informativas:
   - Clique em **Continuar** na tela informativa de provisionamento;
   - Quando for exibida a janela solicitando autorização para chamadas de API, clique obrigatoriamente em **Autorizar** (*Authorize Cloud Shell to make GCP API calls*).

3. Assim que a conexão for estabelecida, você já estará autenticado e o projeto ativo será automaticamente configurado com o ID da sua sessão (`$DEVSHELL_PROJECT_ID`).

4. (Opcional) Verifique a conta ativa executando:

```bash
gcloud auth list
```

*(A conta ativa exibida deve coincidir com o usuário `<ql-variable key="user_0.username"></ql-variable>` marcado com um asterisco `*`).*

5. (Opcional) Confirme o projeto ativo executando:

```bash
gcloud config list project
```
```

---

### Blurb 4: Configuração Dinâmica de Região e Zona
*Origem: `fragments/set-dynamic-zone-region` adaptado para shell dinâmico Qwiklabs*

```markdown
### Configurar a Região e Zona do Laboratório

Determinados recursos de nuvem operam no nível de regiões ou zonas geográficas. Uma região representa uma localização física específica onde seus serviços são executados, composta por uma ou mais zonas de disponibilidade.

Para garantir que todos os comandos da CLI utilizem a localização geográfica atribuída dinamicamente ao seu sandbox, execute o bloco a seguir no Cloud Shell:

```bash
export PROJECT_ID=$DEVSHELL_PROJECT_ID

# Obter dinamicamente a região atribuída ao sandbox pelo Qwiklabs:
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata[google-compute-default-region])" 2>/dev/null)
export REGION=${REGION:-$(gcloud config get-value compute/region 2>/dev/null)}
export REGION=${REGION:-us-central1}

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata[google-compute-default-zone])" 2>/dev/null)
export ZONE=${ZONE:-${REGION}-a}

gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

echo "=========================================="
echo "Projeto Ativo: ${PROJECT_ID}"
echo "Região Ativa:  ${REGION}"
echo "Zona Ativa:    ${ZONE}"
echo "=========================================="
```
```

---

### Blurb 5: Resiliência e Aviso de Respostas Cacheadas (GenAI / LLMs)
*Origem: `fragments/cached-response-disclaimer/en.md`*

```markdown
> ℹ️ **Aviso sobre Respostas e Quotas de Modelos:**  
> Para garantir uma experiência consistente, de alto desempenho e evitar esgotamento de cotas de API (`429 RESOURCE_EXHAUSTED`) durante a execução prática em turmas com múltiplos alunos simultâneos, este laboratório pode fornecer respostas de contingência ou respostas cacheadas para determinadas consultas do modelo.
```

---

### Blurb 6: Diagnóstico e Resolução de Erros de Autenticação no Antigravity CLI
*Origem: `fragments/antigravity-local-setup/en.md`*

```markdown
> ⚠️ **Solução de Problemas de Autenticação e Permissão no Antigravity CLI:**  
> Se o assistente apresentar erros como `Permission 'aiplatform.endpoints.predict' denied` ou `Agent terminated due to error`, certifique-se de que a sessão não foi conectada acidentalmente com uma conta pessoal do Google ou com um ID de projeto incorreto.  
> Para restabelecer o acesso:  
> 1. Execute o comando `agy auth logout` no terminal (ou no menu de configurações do assistente, selecione **Account > Sign Out**).  
> 2. Reinicie o assistente digitando `agy`.  
> 3. Selecione a opção **Use a Google Cloud project** e autentique-se com a conta de estudante `<ql-variable key="user_0.username"></ql-variable>` vinculada ao projeto `<ql-variable key="project_0.project_id"></ql-variable>`.
```

---

### Blurb 7: Encerramento do Laboratório e Avaliação
*Origem: `fragments/endqwiklab/en.md`*

```markdown
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
```

---

### Blurb 8: Governança, Próximos Passos e Direitos Autorais
*Origem: `fragments/training-certification-overview/en.md` e `fragments/copyright/en.md`*

```markdown
### Treinamento e Certificação do Google Cloud

O programa de [Treinamento do Google Cloud](https://cloud.google.com/training) ajuda você a extrair o máximo das tecnologias de computação em nuvem e inteligência artificial. Nossos cursos incluem habilidades técnicas e melhores práticas para acelerar sua jornada profissional, oferecendo formatos sob demanda, presenciais e virtuais. As [Certificações do Google Cloud](https://cloud.google.com/certification/) validam sua experiência comprovada em arquitetura de nuvem e engenharia de IA.

**Manual Last Updated: September 1, 2026**  
**Lab Last Tested: September 1, 2026**

Copyright 2026 Google LLC. Todos os direitos reservados. Google e o logotipo do Google são marcas registradas da Google LLC. Todos os outros nomes de empresas e produtos podem ser marcas registradas das respectivas empresas com as quais estão associados.
```

---

## 5. Matriz de Priorização e Roadmap de Adoção

| Melhoria Proposta | Eixo | Impacto no Aluno | Esforço | Risco no Deploy Manual | Recomendação |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Incorporação dos Blurbs Canônicos** (Incognito, Console, Cloud Shell, Encerramento) | UX / Padronização | **Muito Alto** | Baixo | **Zero risco** | **Fase 1 (Imediata)** |
| **Padronização Textual CLS** (Títulos imperativos, ações únicas, negrito em UI, sem 1ª pessoa) | Editorial | **Alto** | Baixo | **Zero risco** | **Fase 1 (Imediata)** |
| **Guia de Respostas para o `/grill-me` e Exemplo de Relatório** | UX / Conteúdo | **Alto** | Baixo | **Zero risco** | **Fase 1 (Imediata)** |
| **Tabela de Atalhos e Comandos do `agy`** | UX | Médio | Baixo | **Zero risco** | **Fase 1 (Imediata)** |
| **Script de Autoverificação CLI (`check_progress.sh`)** | Avaliação | **Muito Alto** | Médio | **Zero risco** | **Fase 2 (Próxima)** |
| **Plugin de Resiliência a Erro 429 (`Graceful429Plugin`)** | Resiliência | **Muito Alto** | Médio | **Zero risco** | **Fase 2 (Próxima)** |
| **Ajustes de Pre-Warming no `script.sh` do Terraform** | Infraestrutura | Médio | Baixo | Baixo (requer reempacotar `Archive.zip`) | **Fase 2 (Próxima)** |
| **Matriz de Permissões Least Privilege no `AGENTS.md`** | Governança | Médio | Baixo | **Zero risco** | **Fase 3 (Contínua)** |

---

## 6. Próximos Passos Sugeridos

1. **Refinar `lab_instructions.md`**: Aplicar as regras editoriais do CLS Writing Style Guide e incorporar os blurbs canônicos adaptados (login, ativação do Cloud Shell com autorização de pop-up, aviso de quota e encerramento).
2. **Disponibilizar o script `scripts/check_progress.sh`**: Fornecer um validador amigável para Cloud Shell.
3. **Adicionar o fallback de quota 429**: Incorporar o padrão de interceptação do ADK na pasta de suporte do workshop.
