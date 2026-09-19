# Fluxo de Trabalho Detalhado para Due Diligence de Contratos

Este documento contém o protocolo completo e detalhado para a execução de Due Diligence jurídica de contratos comerciais.

## Fluxo de Execução Passo a Passo

### Passo 1: Leitura Inicial e Extração de Metadados
Carregue o contrato na íntegra e extraia as seguintes informações essenciais de identificação:
* **Partes Contratantes:** Razão Social, CNPJ/CPF, endereços e representantes legais.
* **Objeto Principal:** Descrição suscinta da natureza do negócio.
* **Aspectos Financeiros:** Valores, condições de faturamento, multa moratória e juros.
* **Vigência e Foro:** Período de vigência, regras de renovação e foro de eleição.

### Passo 2: Verificação e Auditoria de Riscos (L3)
Carregue o checklist disponível em `references/checklist.md` usando a ferramenta de leitura de recursos. Avalie cada cláusula do contrato à luz das perguntas e critérios do checklist. Atente-se de forma crítica para:
1. **Limitação de Responsabilidade:** Presença de *Liability Cap* razoável e exclusão de danos indiretos/lucros cessantes.
2. **Rescisão:** Reciprocidade nas condições de rescisão imotivada e motivada, prazos de aviso prévio e presença de cláusula de cura (*cure period*).
3. **Propriedade Intelectual (PI):** Divisão clara entre *Background IP* e *Foreground IP*.
4. **Proteção de Dados (LGPD):** Definição precisa de Controlador/Operador e prazos de aviso de incidentes (recomenda-se 24h a 48h).

### Passo 3: Elaboração do Relatório de Due Diligence
Carregue o modelo estruturado em `assets/relatorio_template.md`. Preencha a Matriz de Riscos classificando as cláusulas problemáticas encontradas nos seguintes níveis:
* **Risco Crítico (Alto):** Cláusulas abusivas ou desequilibradas que devem ser obrigatoriamente renegociadas.
* **Risco Moderado (Médio):** Pontos desfavoráveis que devem ser negociados se houver margem comercial para ajuste.
* **Informativo (Baixo):** Pontos padrões de atenção para ciência e gestão operacional do contrato.

### Passo 4: Proposta de Redações Alternativas (Redlines)
Para cada risco identificado como Crítico ou Moderado, elabore cláusulas alternativas equilibradas, justificando-as com base nas melhores práticas do mercado jurídico.
