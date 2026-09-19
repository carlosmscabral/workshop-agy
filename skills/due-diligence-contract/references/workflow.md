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
Carregue o checklist disponível em `references/checklist.md` usando a ferramenta de leitura de recursos. Avalie cada cláusula do contrato social ou comercial à luz dos critérios do checklist. Atente-se de forma crítica para:
1. **Administração e Alçadas:** Poderes da diretoria/administradores, exigência de assinatura conjunta e limites de valor para operações bancárias ou alienação de ativos.
2. **Quotas e Direito de Preferência:** Restrições de cessão/transferência de quotas a terceiros, prazos e condições do direito de preferência dos sócios.
3. **Não Concorrência e Confidencialidade:** Escopo temporal, geográfico e material de não competição (*non-compete*) e obrigações de sigilo.
4. **Responsabilidade, PI e Proteção de Dados (LGPD):** *Liability Cap*, titularidade de Propriedade Intelectual e obrigações de Controlador/Operador.

### Passo 3: Elaboração do Relatório de Due Diligence
Estruture o relatório em Markdown seguindo o modelo abaixo e classificando a Matriz de Riscos em **ALTO** (cláusulas críticas que exigem renegociação/aprovação especial), **MÉDIO** (pontos de atenção moderados) ou **BAIXO** (informativo):

```markdown
### Relatório de Due Diligence Contratual — [Nome da Empresa]

- **Empresa Auditada:** [Nome da Empresa]
- **Classificação Geral de Risco:** [ALTO / MÉDIO / BAIXO]

#### 1. Matriz de Riscos e Cláusulas Críticas
- **Administração:** Avaliação de poderes e limites de assinatura conjunta.
- **Direito de Preferência / Quotas:** Restrições de cessão e prazos.
- **Não Concorrência / Confidencialidade:** Escopo temporal e geográfico.

#### 2. Parecer e Recomendações
Recomendações objetivas e sugestões de ajuste (redlines) para a equipe jurídica e executiva da Cymbal Technologies.
```
