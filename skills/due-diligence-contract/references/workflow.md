# Fluxo de Trabalho Detalhado para Due Diligence de Contratos

Este documento contém o protocolo para a execução de Due Diligence jurídica de contratos sociais e minutas societárias.

## Fluxo de Execução Passo a Passo

### Passo 1: Leitura Inicial e Extração de Metadados
Leia o contrato na íntegra e extraia as seguintes informações de identificação:
* **Sociedade Auditada:** Razão social, nome fantasia, sede e objeto social.
* **Sócios:** Nome ou razão social, CNPJ/CPF e representantes legais.
* **Capital Social:** Valor total, número de quotas e participação de cada sócio.
* **Administração e Foro:** Quem administra a sociedade, regra de assinatura e mecanismo de resolução de conflitos.

### Passo 2: Verificação e Auditoria de Riscos (L3)
Use a ferramenta `load_skill_resource` para carregar o checklist em `references/checklist.md`. Avalie cada cláusula do contrato com as perguntas dos 10 pontos do checklist. Dê atenção especial a:
1. **Administração:** Poderes dos administradores, assinatura isolada ou conjunta, alçadas de valor e quóruns de aprovação.
2. **Direito de Preferência e Quotas:** Restrições de cessão, prazos de exercício, *tag-along* e *drag-along*.
3. **Não Concorrência e Confidencialidade:** Escopo temporal, escopo geográfico e valor das penalidades.
4. **Passivos e Contingências:** Processos, dívidas e declarações que afetam o valor da sociedade.

Se o contrato não trata de um ponto do checklist, registre a ausência como achado.

### Passo 3: Elaboração do Relatório de Due Diligence
Use a ferramenta `load_skill_resource` para carregar o modelo em `assets/relatorio_template.md`. Siga a estrutura do modelo sem alterar os títulos. Classifique cada item da Matriz de Riscos em um destes níveis:
* **ALTO:** Cláusula desequilibrada, omissa ou contingência relevante que exige renegociação ou tratamento antes do fechamento.
* **MÉDIO:** Ponto desfavorável que a equipe deve negociar se houver margem.
* **BAIXO:** Ponto padrão, registrado apenas para ciência.

Cite a cláusula do contrato em cada item. A **Classificação Geral de Risco** é o nível mais alto encontrado na matriz.

### Passo 4: Parecer e Recomendações
Na seção **Parecer e Recomendações**, escreva recomendações objetivas para a equipe jurídica e executiva da Cymbal Technologies. Para cada risco ALTO ou MÉDIO, proponha uma redação alternativa da cláusula e justifique a proposta.
