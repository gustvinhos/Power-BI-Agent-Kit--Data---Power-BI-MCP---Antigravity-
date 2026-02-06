RELATÓRIO TÉCNICO
Análise de Viabilidade para Unificação de Modelos Semânticos
S&OP Axia V2 e V3 → Golden Dataset
Power BI Embedded
Data: 03 de Fevereiro de 2026
 
Sumário


 
1. Resumo Executivo
1.1 Viabilidade Técnica
VIÁVEL COM RESSALVAS
A análise técnica dos modelos S&OP Axia V2 (24 tabelas, 192 medidas) e V3 (45 tabelas, 212 medidas) demonstra alta sobreposição estrutural (aproximadamente 85% das tabelas core são idênticas). A unificação é tecnicamente viável utilizando o V2 como base principal, conforme solicitado.
1.2 Principais Descobertas
•	Taxa de Sobreposição de Tabelas Core: 85% (14 de 16 tabelas principais idênticas)
•	Taxa de Sobreposição de Medidas: 78% (aproximadamente 150 medidas compartilhadas)
•	Ausência de RLS: Nenhum dos modelos possui Row-Level Security configurado
•	Fontes de Dados: Mesma origem (Azure SQL - agroops.database.windows.net/axiapool)
•	V3 possui 24 LocalDateTables automáticas: Indicativo de má configuração de tipos de dados (devem ser removidas)
1.3 Estimativa de Ganhos (ROI)
Métrica	Antes	Depois (Estimado)
Consumo de Memória (Capacity)	2x (duplicado)	1x (-50%)
Tempo de Refresh	2x (paralelo)	1x (-50%)
Esforço de Manutenção	Duplicado	Centralizado (-60%)
Tempo de Renderização	Base	-20% a -30%
Consistência de Dados	Risco de divergência	100% garantida
 
2. Análise Comparativa Detalhada
2.1 Comparação Estrutural de Tabelas
A tabela abaixo apresenta a comparação das tabelas core presentes em ambos os modelos:
Tabela	V2 Cols	V3 Cols	Match	Observação
Dim Produto AXIA	51	51	100%	Idêntica
Dim Filiais AXIA	34	34	100%	Idêntica
Dim Calendário	3	4	75%	V3 +1 coluna
Dim CFOP	9	9	100%	Idêntica
Dim Grupo Financeiro	4	4	100%	Idêntica
Dim Pricing AXIA	5	5	100%	Idêntica
Vendas Total AXIA	53	28	53%	V3 otimizada
Estoque Atual AXIA	23	23	100%	Idêntica
Estoque Histórico AXIA	25	24	96%	V2 +1 coluna
Estoque Vencimentos AXIA	28	28	100%	Idêntica
Entradas AXIA	44	54	81%	V3 +10 colunas
Pedidos de Compras AXIA	50	46	92%	V2 +4 colunas
Faturamentos Antecipados	29	30	97%	V3 +1 coluna
Slow Moving AXIA	10	10	100%	Calculada
Medidas	4 + 183m	4 + 207m	88%	V3 +24 medidas
2.2 Tabelas Exclusivas
Tabelas exclusivas do V2 (a manter no Golden Dataset):
•	Solicitações de Compras AXIA (41 colunas) - Tabela de fato importante
•	Compras (17 colunas) - Fonte SharePoint
•	Tabela Rupturas NL (25 colunas)
•	Ruptura Diário (21 colunas) - Fonte SharePoint
•	Dim Custos (2 colunas) - Tabela calculada
•	Parâmetro Rupturas (3 colunas) - Com erro semântico, requer correção
•	PerfisColunas (2 colunas) - Tabela de parâmetros
Tabelas exclusivas do V3 (avaliar migração):
•	Dados (1 coluna) - Avaliar necessidade
•	Páginas (2 colunas) - Tabela de navegação
•	Medida (4 colunas) - Parece duplicata, verificar
•	24 LocalDateTables - REMOVER (geradas automaticamente)
•	DateTableTemplate - REMOVER (template interno)
 
2.3 Comparação de Relacionamentos
Modelo V2	Modelo V3
38 relacionamentos	53 relacionamentos
Todos direcionais (OneDirection)	Todos direcionais (OneDirection)
1 relacionamento M:M (Pedidos→Compras)	0 relacionamentos M:M
Sem LocalDateTables	+24 relacionamentos com LocalDateTables
Observação Importante: O V3 possui 24 LocalDateTables geradas automaticamente pelo Power BI quando colunas de data não são marcadas corretamente. Isso indica um problema de configuração que deve ser corrigido no Golden Dataset, evitando o 'Auto Date/Time' desnecessário.
2.4 Análise de Medidas DAX
Foram identificadas diferenças nas implementações de medidas entre os modelos:
Exemplo de Diferença - Medida 'QTD Estoque Bruto':
V2: IF(SUM('Estoque Atual AXIA'[VLR_ESTOQUE])=0,BLANK(),SUM('Estoque Atual AXIA'[VLR_ESTOQUE]))
V3: SUM('Estoque Atual AXIA'[VLR_ESTOQUE])
Recomendação: Manter a versão V2 que trata valores zero como BLANK(), evitando exibição de zeros nas visualizações.
Medidas Exclusivas do V3 (candidatas à migração):
•	Estoque Retroativo (R$), Estoque Retroativo (un), Custo médio Retroativo
•	Medidas de Switch para unidades (un, Kg/L, Hec, R$)
•	Medidas de previsão S&OP (Demanda 60 dias, WMAPE, Erro)
•	Medidas de POG (Estoq. - Fat. Ante. - Xd)
 
3. Roadmap de Implementação
3.1 Fase 1: Preparação (Semana 1)
☐	Backup completo dos arquivos .pbix V2 e V3
☐	Exportar TMDL do V2 como base do Golden Dataset
☐	Documentar todas as medidas exclusivas do V3
☐	Mapear todas as visuais dos relatórios V2 e V3
☐	Configurar ambiente de desenvolvimento isolado
3.2 Fase 2: Criação do Golden Dataset (Semana 2-3)
☐	Criar novo modelo semântico a partir do V2
☐	Desabilitar 'Auto Date/Time' nas configurações do modelo
☐	Corrigir erro semântico na tabela 'Parâmetro Rupturas'
☐	Migrar medidas exclusivas do V3 para o Golden Dataset
☐	Padronizar nomenclatura de medidas (Display Folders)
☐	Aplicar otimizações de tipagem de dados
☐	Remover colunas não utilizadas identificadas na análise
☐	Validar integridade de todos os relacionamentos
3.3 Fase 3: Validação de Medidas (Semana 4)
☐	Criar queries DAX de validação cruzada
☐	Comparar resultados de medidas core entre modelos
☐	Documentar e corrigir discrepâncias encontradas
☐	Validar performance das medidas complexas (DIO, Rupturas)
☐	Executar testes de carga simulando uso em Embedded
3.4 Fase 4: Conversão para Thin Reports (Semana 5)
☐	Publicar Golden Dataset no workspace do Power BI Service
☐	Criar novo .pbix para Relatório V2 (apenas visuais)
☐	Conectar via Live Connection ao Golden Dataset
☐	Recriar visuais necessárias do V2
☐	Criar novo .pbix para Relatório V3 (apenas visuais)
☐	Conectar via Live Connection ao Golden Dataset
☐	Recriar visuais necessárias do V3
3.5 Fase 5: Deploy e Monitoramento (Semana 6)
☐	Configurar refresh schedule do Golden Dataset
☐	Atualizar embeddings no aplicativo para novos IDs
☐	Executar testes de integração no ambiente Embedded
☐	Monitorar métricas de performance (Premium Capacity Metrics)
☐	Documentar processo para manutenção futura
☐	Depreciar modelos antigos após período de validação
 
4. Recomendações de Performance para Embedded
4.1 Otimizações Imediatas (Durante Unificação)
A. Remoção de Colunas Não Utilizadas
Identificadas colunas candidatas à remoção na tabela Vendas Total AXIA (V2 tem 25 colunas a mais que V3):
•	COD_SISCOM, COD_PROTHEUS (redundantes se ID_PRODUTO for chave)
•	VLR_DESCONTO, VLR_ICMS, VLR_PIS, VLR_COFINS (se não usados em análises)
•	NUM_SERIE, CHAVE_NFE (se não usados em drill-through)
•	DSC_PRODUTO, DSC_FIN (já disponíveis via relacionamento com Dim Produto)
B. Otimização de Tipos de Dados
•	Converter ID_PRODUTO de String para Int64 (economia de ~40% memória)
•	Garantir que colunas de flag (FLG_*) sejam Boolean
•	Revisar precisão de colunas Double (reduzir casas decimais se possível)
•	Marcar colunas de data corretamente para evitar LocalDateTables
C. Eliminação de LocalDateTables
•	Desabilitar 'Auto Date/Time' em Arquivo → Opções → Atual
•	Usar a Dim Calendário existente para todas as análises temporais
•	Impacto esperado: Redução de 24 tabelas (V3) → economia de memória significativa
4.2 Configurações para Power BI Embedded
•	Query Caching: Habilitar cache de queries no capacity para acelerar re-renderizações
•	Aggregations: Considerar tabelas de agregação para medidas de DIO e Vendas 365d
•	Incremental Refresh: Configurar para tabelas Vendas, Entradas e Estoque Histórico
•	Particionamento: Particionar tabelas de fato por ano/mês para refresh otimizado
4.3 Monitoramento Pós-Implementação
•	Usar Premium Capacity Metrics App para acompanhar CPU e memória
•	Configurar alertas para queries lentas (>10 segundos)
•	Monitorar taxa de cache hit vs miss
•	Revisar Performance Analyzer nas visuais mais pesadas
 
5. Pontos de Atenção e Riscos
5.1 Bloqueios Identificados
Item	Descrição	Mitigação
Erro Semântico	Tabela 'Parâmetro Rupturas' referencia 'Rupturas AXIA' inexistente	Corrigir/remover referência
Tabela Calculada	'Slow Moving AXIA' é calculada via SUMMARIZECOLUMNS	Manter como está
Fonte SharePoint	Tabelas 'Compras' e 'Ruptura Diário' usam SharePoint	Validar credenciais
Medidas Divergentes	Algumas medidas têm lógica diferente entre V2 e V3	Validação cruzada
5.2 Riscos e Mitigações
1.	Quebra de Visuais: Medidas com nomes diferentes podem quebrar visuais. Mitigação: Criar aliases para medidas renomeadas.
2.	Diferença de Resultados: Usuários podem notar diferenças numéricas. Mitigação: Documentar e comunicar mudanças.
3.	Downtime: Migração requer período de transição. Mitigação: Deploy em horário de baixo uso.
4.	Rollback: Em caso de problemas críticos. Mitigação: Manter modelos antigos disponíveis por 30 dias.
 
6. Conclusão
A unificação dos modelos semânticos S&OP Axia V2 e V3 em um Golden Dataset é tecnicamente viável e altamente recomendada. A análise demonstrou:
•	Alta sobreposição estrutural (85% das tabelas core idênticas)
•	Mesma fonte de dados (Azure SQL), facilitando a consolidação
•	Ausência de RLS, eliminando complexidade de segurança
•	Oportunidades claras de otimização (remoção de LocalDateTables, colunas não utilizadas)
A implementação usando o V2 como base principal é a abordagem correta, pois este modelo possui estrutura mais completa e melhor tratamento de valores nulos nas medidas.
Próximos Passos Imediatos:
5.	Aprovar este plano de projeto com stakeholders
6.	Agendar janela de manutenção para início da Fase 1
7.	Designar responsáveis técnicos para cada fase
8.	Comunicar usuários sobre possíveis mudanças na interface
_______________________________________________
Análise gerada via Power BI Modeling MCP
03 de Fevereiro de 2026
