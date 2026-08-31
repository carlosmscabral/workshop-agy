---
name: due-diligence-contract
description: Protocolo de análise jurídica aplicável estritamente quando um contrato é fornecido pelo usuário.
---

# [IMPORTANTE] UTILIZAR ESTA SKILL AO RECEBER CONTRATOS

Esta skill é ativada quando o usuário demonstra interesse ou solicita análise/due diligence de um contrato. Para evitar o consumo desnecessário de tokens antes de o arquivo/texto estar disponível, siga as diretrizes abaixo.

## Regra de Ativação (Gating Rule)
* **Verificação Obrigatória:** Antes de carregar qualquer recurso adicional, verifique se o usuário já forneceu/colou o conteúdo ou o arquivo do contrato no chat.
* **Se o contrato NÃO foi fornecido:** **NÃO chame** a ferramenta `load_skill_resource` e não carregue nenhum arquivo L3. Responda ao usuário solicitando de forma cordial que ele envie ou cole o texto do contrato para iniciar a due diligence.
* **Se o contrato JÁ foi fornecido:** Prossiga imediatamente para a etapa de carregamento de instruções.

## Instruções Básicas (Apenas após o contrato ser fornecido)
1. Use a ferramenta `load_skill_resource` para ler o fluxo de execução detalhado em `references/workflow.md`.
2. Siga estritamente as diretrizes contidas no recurso `references/workflow.md` para auditar o contrato fornecido e estruturar o seu relatório.
