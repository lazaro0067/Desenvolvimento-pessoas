# 📊 Guia de Monitoramento - Plataforma Desenvolvimento de Pessoas

## 🎯 Visão Geral
Este guia detalha como monitorar, diagnosticar e resolver problemas da aplicação em produção no Azure.

---

## 📈 Dashboards e Métricas

### 1. Portal Azure - Visão Geral

Acesse: https://portal.azure.com → Resource Groups → `rg-desenvolvimento-pessoas` → `desenvolvimento-pessoas`

**Métricas Principais:**
- 📊 **Requests** - Total de requisições HTTP
- ⚡ **Response Time** - Tempo médio de resposta
- 💾 **Memory Usage** - Uso de memória (%)
- 🔥 **CPU Usage** - Uso de CPU (%)
- ⚠️ **Errors** - Taxa de erros 4xx/5xx
- 🔄 **Replica Count** - Número de instâncias ativas

### 2. Visualizar Métricas em Tempo Real

```powershell
# Requests por minuto (últimas 24h)
az monitor metrics list `
  --resource "/subscriptions/{subscription-id}/resourceGroups/rg-desenvolvimento-pessoas/providers/Microsoft.App/containerApps/desenvolvimento-pessoas" `
  --metric "Requests" `
  --start-time (Get-Date).AddDays(-1) `
  --interval PT1M `
  --output table

# CPU e Memória
az monitor metrics list `
  --resource "/subscriptions/{subscription-id}/resourceGroups/rg-desenvolvimento-pessoas/providers/Microsoft.App/containerApps/desenvolvimento-pessoas" `
  --metric "UsageNanoCores,WorkingSetBytes" `
  --start-time (Get-Date).AddHours(-1) `
  --interval PT1M `
  --output table
```

---

## 📋 Logs e Diagnóstico

### 1. Ver Logs em Tempo Real

```powershell
# Logs contínuos (similar a tail -f)
az containerapp logs show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --follow

# Logs das últimas 2 horas
az containerapp logs show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --tail 500
```

### 2. Filtrar Logs Específicos

```powershell
# Filtrar apenas erros
az containerapp logs show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --tail 200 | Select-String -Pattern "error|exception|fail" -CaseSensitive:$false

# Filtrar requisições de um endpoint específico
az containerapp logs show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --tail 500 | Select-String -Pattern "/api/chat"
```

### 3. Log Analytics (Avançado)

No Portal Azure: Container App → **Logs** (menu lateral)

**Queries KQL Úteis:**

```kql
// ═══════════════════════════════════════════════════════
// 🔴 ERROS E EXCEÇÕES (últimas 24h)
// ═══════════════════════════════════════════════════════
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(24h)
| where Log_s contains "error" or Log_s contains "exception"
| project TimeGenerated, Log_s
| order by TimeGenerated desc
| take 100

// ═══════════════════════════════════════════════════════
// 📊 REQUISIÇÕES POR ENDPOINT (top 10)
// ═══════════════════════════════════════════════════════
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(1h)
| where Log_s matches regex @"(GET|POST|PUT|DELETE)\s+(/[^\s]+)"
| extend Method = extract(@"(GET|POST|PUT|DELETE)", 1, Log_s)
| extend Endpoint = extract(@"(GET|POST|PUT|DELETE)\s+([^\s]+)", 2, Log_s)
| summarize Count = count() by Endpoint, Method
| order by Count desc
| take 10

// ═══════════════════════════════════════════════════════
// ⚡ TEMPO DE RESPOSTA (milissegundos)
// ═══════════════════════════════════════════════════════
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(1h)
| where Log_s matches regex @"completed in (\d+)ms"
| extend ResponseTime = toint(extract(@"completed in (\d+)ms", 1, Log_s))
| summarize 
	AvgResponseTime = avg(ResponseTime),
	P50 = percentile(ResponseTime, 50),
	P95 = percentile(ResponseTime, 95),
	P99 = percentile(ResponseTime, 99)
| project AvgResponseTime, P50, P95, P99

// ═══════════════════════════════════════════════════════
// 🚀 STATUS HTTP (distribuição)
// ═══════════════════════════════════════════════════════
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(1h)
| where Log_s matches regex @"HTTP/[\d\.]+ (\d+)"
| extend StatusCode = toint(extract(@"HTTP/[\d\.]+ (\d+)", 1, Log_s))
| summarize Count = count() by StatusCode
| order by StatusCode asc

// ═══════════════════════════════════════════════════════
// 👥 USUÁRIOS ATIVOS (por userId nos logs)
// ═══════════════════════════════════════════════════════
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(24h)
| where Log_s matches regex @"userId[:\s]+([a-f0-9\-]{36})"
| extend UserId = extract(@"userId[:\s]+([a-f0-9\-]{36})", 1, Log_s)
| summarize UniqueUsers = dcount(UserId)

// ═══════════════════════════════════════════════════════
// 💥 CRASHES E RESTART (container restarts)
// ═══════════════════════════════════════════════════════
ContainerAppSystemLogs_CL
| where TimeGenerated > ago(7d)
| where Reason_s == "ContainerRestart"
| project TimeGenerated, Reason_s, Log_s
| order by TimeGenerated desc

// ═══════════════════════════════════════════════════════
// 🔥 CPU E MEMÓRIA (uso ao longo do tempo)
// ═══════════════════════════════════════════════════════
ContainerAppSystemLogs_CL
| where TimeGenerated > ago(1h)
| summarize 
	AvgCpu = avg(todouble(CpuPercent_d)),
	AvgMemory = avg(todouble(MemoryPercent_d))
	by bin(TimeGenerated, 5m)
| project TimeGenerated, AvgCpu, AvgMemory
| render timechart
```

---

## 🚨 Alertas Automatizados

### 1. Criar Alerta de Alta Taxa de Erros

```powershell
# Alerta quando taxa de erro > 10% em 5 minutos
az monitor metrics alert create `
  --name "high-error-rate" `
  --resource-group rg-desenvolvimento-pessoas `
  --scopes "/subscriptions/{subscription-id}/resourceGroups/rg-desenvolvimento-pessoas/providers/Microsoft.App/containerApps/desenvolvimento-pessoas" `
  --condition "count Errors > 50" `
  --window-size 5m `
  --evaluation-frequency 1m `
  --severity 2 `
  --description "Taxa de erros acima de 50 em 5 minutos"
```

### 2. Criar Alerta de CPU Alto

```powershell
az monitor metrics alert create `
  --name "high-cpu-usage" `
  --resource-group rg-desenvolvimento-pessoas `
  --scopes "/subscriptions/{subscription-id}/resourceGroups/rg-desenvolvimento-pessoas/providers/Microsoft.App/containerApps/desenvolvimento-pessoas" `
  --condition "avg UsageNanoCores > 0.8" `
  --window-size 10m `
  --evaluation-frequency 5m `
  --severity 3 `
  --description "CPU acima de 80% por 10 minutos"
```

### 3. Configurar Action Group (Notificações)

```powershell
# Criar grupo de ação para enviar email
az monitor action-group create `
  --name "admin-alerts" `
  --resource-group rg-desenvolvimento-pessoas `
  --short-name "AdminAlert" `
  --email admin email@example.com `
  --email admin2 email2@example.com
```

---

## 🔧 Diagnóstico de Problemas Comuns

### ⚠️ Problema 1: Alta Latência (Resposta Lenta)

**Sintomas:**
- Tempo de resposta > 2 segundos
- Usuários reclamando de lentidão

**Diagnóstico:**
```powershell
# Verificar CPU e Memória
az containerapp show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --query "properties.template.containers[0].resources"

# Ver logs de performance
az containerapp logs show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --tail 100 | Select-String -Pattern "ms|milliseconds"
```

**Soluções:**
1. **Aumentar recursos do container:**
```powershell
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --cpu 1.0 `
  --memory 2.0Gi
```

2. **Aumentar número de réplicas:**
```powershell
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --min-replicas 2 `
  --max-replicas 5
```

3. **Otimizar queries do banco de dados** (adicionar índices, revisar N+1)

---

### ⚠️ Problema 2: Muitos Erros 500

**Sintomas:**
- Logs cheios de "Internal Server Error"
- Swagger retorna 500

**Diagnóstico:**
```powershell
# Ver stack traces completos
az containerapp logs show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --tail 500 | Select-String -Pattern "exception" -Context 5,10
```

**Soluções:**
1. **Verificar connection string do banco:**
```powershell
az containerapp show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --query "properties.template.containers[0].env[?name=='ConnectionStrings__DefaultConnection'].value"
```

2. **Testar conexão com SQL Database:**
```powershell
# Verificar firewall
az sql server firewall-rule list `
  --server sql-desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas
```

3. **Executar migrations pendentes:**
```powershell
# Conectar via SSMS ou Azure Data Studio e executar:
# dotnet ef database update
```

---

### ⚠️ Problema 3: Container Reiniciando Constantemente

**Sintomas:**
- App fica indisponível intermitentemente
- Logs mostram "Container restarting"

**Diagnóstico:**
```powershell
# Ver eventos de restart
az containerapp logs show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --tail 200 | Select-String -Pattern "restart|crash|killed"
```

**Soluções:**
1. **Verificar se app está causando OOM (Out of Memory):**
```powershell
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --memory 2.0Gi  # Aumentar memória
```

2. **Verificar health check:**
```powershell
# Testar endpoint de health
Invoke-RestMethod -Uri "https://{seu-app-url}/health"
```

---

### ⚠️ Problema 4: Database Connection Timeout

**Sintomas:**
- "Unable to connect to SQL Server"
- "Connection timeout expired"

**Diagnóstico:**
```powershell
# Testar conexão do Azure Cloud Shell
sqlcmd -S sql-desenvolvimento-pessoas.database.windows.net `
  -d DesenvPessoasDb `
  -U admindesenv `
  -P 'SuaSenha123!@#' `
  -Q "SELECT @@VERSION"
```

**Soluções:**
1. **Adicionar firewall rule para Azure Services:**
```powershell
az sql server firewall-rule create `
  --resource-group rg-desenvolvimento-pessoas `
  --server sql-desenvolvimento-pessoas `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0
```

2. **Aumentar timeout na connection string:**
```
Connection Timeout=60;  # Aumentar de 30 para 60 segundos
```

---

## 📊 Performance Tuning

### 1. Configurar Auto-escala Baseada em Carga

```powershell
# Escalar entre 1-10 réplicas baseado em CPU
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --min-replicas 1 `
  --max-replicas 10 `
  --scale-rule-name cpu-scale `
  --scale-rule-type cpu `
  --scale-rule-metadata "type=Utilization" "value=70"
```

### 2. Configurar Escala Baseada em Requisições

```powershell
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --scale-rule-name http-scale `
  --scale-rule-type http `
  --scale-rule-http-concurrency 50  # Escalar quando > 50 req simultâneas
```

### 3. Habilitar Application Insights (APM Completo)

```powershell
# Criar Application Insights
az monitor app-insights component create `
  --app desenvolvimento-pessoas-insights `
  --location brazilsouth `
  --resource-group rg-desenvolvimento-pessoas `
  --application-type web

# Obter instrumentation key
$insightsKey = az monitor app-insights component show `
  --app desenvolvimento-pessoas-insights `
  --resource-group rg-desenvolvimento-pessoas `
  --query instrumentationKey -o tsv

# Adicionar ao Container App
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --set-env-vars "APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=$insightsKey"
```

**No código, adicionar pacote NuGet:**
```powershell
dotnet add src/Api package Microsoft.ApplicationInsights.AspNetCore
```

**Program.cs:**
```csharp
builder.Services.AddApplicationInsightsTelemetry();
```

---

## 🎯 Checklist de Saúde da Aplicação

### Diário (Automático via Alertas)
- [ ] Taxa de erro < 5%
- [ ] Tempo de resposta médio < 500ms
- [ ] CPU < 70%
- [ ] Memória < 80%
- [ ] Zero restarts não planejados

### Semanal (Manual)
- [ ] Revisar logs de erro
- [ ] Verificar crescimento do banco de dados
- [ ] Validar custos Azure
- [ ] Testar backups
- [ ] Atualizar dependências NuGet

### Mensal (Manual)
- [ ] Análise completa de performance
- [ ] Review de security vulnerabilities
- [ ] Otimizar queries lentas
- [ ] Limpar dados antigos (logs, sessions)
- [ ] Atualizar documentação

---

## 📞 Suporte e Escalação

### Níveis de Severidade

**🔴 CRÍTICO (P1)** - App completamente fora do ar
- ⏱️ **SLA:** Resposta em 15 minutos
- 🎯 **Ação:** Rollback imediato para última versão estável

**🟠 ALTO (P2)** - Funcionalidade crítica quebrada
- ⏱️ **SLA:** Resposta em 1 hora
- 🎯 **Ação:** Investigar e aplicar hotfix

**🟡 MÉDIO (P3)** - Performance degradada
- ⏱️ **SLA:** Resposta em 4 horas
- 🎯 **Ação:** Análise de root cause e plano de correção

**🟢 BAIXO (P4)** - Bug menor ou melhoria
- ⏱️ **SLA:** Resposta em 24 horas
- 🎯 **Ação:** Incluir no próximo sprint

---

## 📚 Recursos e Ferramentas

### Ferramentas Recomendadas
- **Azure CLI** - Gerenciamento via linha de comando
- **Azure Portal** - Interface web completa
- **Azure Data Studio** - Gerenciar SQL Database
- **Postman** - Testar APIs
- **Application Insights** - APM e telemetria avançada
- **Grafana** - Dashboards customizados (integração com Azure Monitor)

### Links Úteis
- **Status do Azure:** https://status.azure.com/
- **Documentação Container Apps:** https://learn.microsoft.com/azure/container-apps/
- **Suporte Azure:** https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade
- **Calculadora de Preços:** https://azure.microsoft.com/pricing/calculator/

---

**Criado por:** Guia de Monitoramento Automatizado  
**Última atualização:** 2025-06-01  
**Versão:** 1.0
