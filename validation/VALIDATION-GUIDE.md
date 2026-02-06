# 📊 Guia de Execução - Validação Fase 3

## 🎯 Objetivo
Validar a consistência e performance das medidas entre os modelos V2, V3 e Golden Dataset.

---

## 📋 Pré-requisitos

- [ ] Power BI Desktop com modelo V2 aberto
- [ ] Power BI Desktop com modelo V3 aberto  
- [ ] Power BI Desktop com Golden Dataset aberto
- [ ] Performance Analyzer habilitado
- [ ] DAX Studio instalado (opcional, mas recomendado)

---

## 🔄 Workflow de Validação

### **Etapa 1: Validação de Medidas Core**

**Arquivo:** `01-core-measures-comparison.dax`

1. Abra o modelo **V2** no Power BI Desktop
2. Vá em **Transformar Dados** → **Consultas Avançadas**
3. Cole a query do **Grupo 1 (Medidas de Estoque)**
4. Execute e exporte resultados para: `validation/results/V2_estoque_20260203.csv`
5. Repita para **Grupo 2, 3 e 4** (descomente cada grupo)
6. Repita todo o processo para **V3** e **Golden Dataset**

**Critério de Sucesso:**
- ✅ Diferença < 0.01% entre V2 e Golden
- ✅ Diferença < 0.01% entre V3 e Golden (medidas compartilhadas)

---

### **Etapa 2: Validação de Integridade de Relacionamentos**

**Arquivo:** `02-relationship-integrity.dax`

1. Execute **Teste 1** (Vendas sem Produto) no **V2**
2. Resultado esperado: **Tabela vazia** (sem órfãos)
3. Se houver resultados, documente em `validation/results/integrity-issues.md`
4. Repita **Testes 2-6** individualmente
5. Execute todos os testes no **Golden Dataset**

**Critério de Sucesso:**
- ✅ Testes 1-4: Tabelas vazias (sem órfãos)
- ✅ Teste 5: Produtos inativos identificados (OK se houver)
- ✅ Teste 6: Sem datas fora do calendário

---

### **Etapa 3: Baseline de Performance**

**Arquivo:** `03-performance-baseline.dax`

1. Abra **Performance Analyzer** no Power BI Desktop
2. Execute **Teste 1 (DIO)** no modelo **V2**
3. Registre métricas:
   - Query Duration
   - SE CPU Time
   - SE Query Duration
4. Documente em `validation/results/performance-baseline.md`
5. Repita para **V3** e **Golden Dataset**
6. Execute **Testes 2-6**

**Critério de Sucesso:**
- ✅ Golden Dataset ≤ V2 em performance
- ✅ Nenhuma query > 10 segundos
- ✅ Queries complexas (DIO, Rupturas) < 5 segundos

---

### **Etapa 4: Validação de Medidas Exclusivas V3**

**Arquivo:** `04-v3-exclusive-measures.dax`

⚠️ **IMPORTANTE:** Execute apenas em **V3** e **Golden Dataset** (não existe no V2)

1. Execute **Teste de Existência** no **Golden Dataset**
2. Verifique se todas as medidas retornam `TRUE`
3. Execute **Grupo 1 (Estoque Retroativo)** no **V3**
4. Exporte resultados: `validation/results/V3_retroativo_20260203.csv`
5. Execute no **Golden Dataset** e compare
6. Repita para **Grupos 2-4**

**Critério de Sucesso:**
- ✅ Todas as medidas existem no Golden Dataset
- ✅ Diferença = 0% entre V3 e Golden

---

## 📊 Estrutura de Resultados

```
validation/
├── queries/
│   ├── 01-core-measures-comparison.dax
│   ├── 02-relationship-integrity.dax
│   ├── 03-performance-baseline.dax
│   └── 04-v3-exclusive-measures.dax
└── results/
    ├── V2_estoque_20260203.csv
    ├── V2_vendas_20260203.csv
    ├── V3_estoque_20260203.csv
    ├── V3_vendas_20260203.csv
    ├── Golden_estoque_20260203.csv
    ├── Golden_vendas_20260203.csv
    ├── performance-baseline.md
    ├── integrity-issues.md (se houver)
    └── discrepancies.md (se houver)
```

---

## 🛠️ Ferramentas Recomendadas

### **Opção 1: Power BI Desktop (Nativo)**
- Transformar Dados → Consultas Avançadas
- Performance Analyzer
- Exportar resultados manualmente

### **Opção 2: DAX Studio (Recomendado)**
- Conectar ao modelo via localhost
- Executar queries com métricas detalhadas
- Exportar resultados automaticamente
- Ver plano de execução (Server Timings)

**Comando DAX Studio:**
```powershell
# Conectar ao V2
daxstudio.exe /server "localhost:62323"

# Conectar ao V3
daxstudio.exe /server "localhost:52118"
```

---

## 📝 Template de Documentação de Discrepâncias

Salvar em: `validation/results/discrepancies.md`

```markdown
# Discrepâncias Encontradas - Validação Fase 3

## Data: 2026-02-03

### Discrepância #1
- **Medida:** [Nome da Medida]
- **Modelo V2:** 1,234,567.89
- **Modelo V3:** 1,234,500.00
- **Golden Dataset:** 1,234,567.89
- **Diferença:** 0.005% (V3 vs Golden)
- **Status:** ⚠️ Requer Investigação
- **Causa Raiz:** [Descrição]
- **Ação Corretiva:** [Descrição]

### Discrepância #2
...
```

---

## ✅ Checklist de Validação Completa

- [ ] **Etapa 1:** Medidas Core validadas (4 grupos)
- [ ] **Etapa 2:** Integridade de relacionamentos validada (6 testes)
- [ ] **Etapa 3:** Baseline de performance estabelecido (6 testes)
- [ ] **Etapa 4:** Medidas exclusivas V3 validadas (4 grupos)
- [ ] Todos os resultados exportados para `validation/results/`
- [ ] Discrepâncias documentadas (se houver)
- [ ] Performance dentro dos critérios estabelecidos
- [ ] Relatório de validação criado

---

## 🚀 Próximos Passos

Após completar todas as validações:

1. Revisar `validation/results/discrepancies.md`
2. Corrigir discrepâncias encontradas (se houver)
3. Re-executar validações nas medidas corrigidas
4. Criar relatório consolidado de validação
5. Avançar para **Fase 4: Conversão para Thin Reports**

---

## 📞 Suporte

Em caso de dúvidas ou problemas:
- Consultar documentação em `docs/runbooks/fase-3-validacao.md`
- Verificar best practices em `best-practices/`
- Revisar agentes especializados em `.agents/agents/`
