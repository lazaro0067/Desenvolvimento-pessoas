# 📘 Guia Completo de Deploy no Azure

## 🎯 Visão Geral
Este guia documenta o processo completo de publicação da Plataforma de Desenvolvimento de Pessoas no Azure usando Container Apps e Azure SQL Database.

---

## 🚀 Deploy Automatizado (RECOMENDADO)

### Pré-requisitos Comprovados ✅
- [x] Conta Azure criada (veja `AZURE_SETUP.md`)
- [x] Azure CLI instalado e configurado
- [x] Docker Desktop instalado e rodando
- [x] Login no Azure feito (`az login`)

### Executar Deploy Automático

```powershell
# No diretório raiz do projeto
.\deploy-azure.ps1
```

**O script fará automaticamente:**
1. ✅ Validar Azure CLI e autenticação
2. ✅ Criar Resource Group no Brasil Sul
3. ✅ Criar Azure Container Registry
4. ✅ Criar SQL Server e Database
5. ✅ Fazer build da imagem Docker
6. ✅ Enviar imagem para Azure Container Registry
7. ✅ Criar Azure Container Apps Environment
8. ✅ Fazer deploy da aplicação
9. ✅ Gerar URL pública e credenciais

**Tempo estimado:** 10-15 minutos

---

## 📋 Deploy Manual (Passo-a-Passo)

Se preferir fazer manualmente ou entender cada etapa:

### 1. Definir Variáveis

```powershell
$ResourceGroup = "rg-desenvolvimento-pessoas"
$Location = "brazilsouth"
$AppName = "desenvolvimento-pessoas"
$SqlServer = "sql-desenvolvimento-pessoas"
$SqlDatabase = "DesenvPessoasDb"
$SqlAdminUser = "admindesenv"
$SqlAdminPassword = "SuaSenhaForte123!@#"  # Trocar!
$ContainerRegistry = "acrdesenvolvimento"
```

### 2. Autenticar no Azure

```powershell
az login
az account show
```

### 3. Criar Resource Group

```powershell
az group create `
  --name $ResourceGroup `
  --location $Location
```

### 4. Criar Azure Container Registry

```powershell
az acr create `
  --resource-group $ResourceGroup `
  --name $ContainerRegistry `
  --sku Basic `
  --admin-enabled true
```

### 5. Criar SQL Server

```powershell
az sql server create `
  --name $SqlServer `
  --resource-group $ResourceGroup `
  --location $Location `
  --admin-user $SqlAdminUser `
  --admin-password $SqlAdminPassword
```

### 6. Configurar Firewall do SQL Server

```powershell
# Permitir serviços do Azure
az sql server firewall-rule create `
  --resource-group $ResourceGroup `
  --server $SqlServer `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0

# Permitir seu IP (opcional, para gerenciar via SSMS)
$meuIp = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()
az sql server firewall-rule create `
  --resource-group $ResourceGroup `
  --server $SqlServer `
  --name AllowMyIP `
  --start-ip-address $meuIp `
  --end-ip-address $meuIp
```

### 7. Criar Database

```powershell
az sql db create `
  --resource-group $ResourceGroup `
  --server $SqlServer `
  --name $SqlDatabase `
  --service-objective Basic `
  --backup-storage-redundancy Local
```

### 8. Construir Connection String

```powershell
$ConnectionString = "Server=tcp:$SqlServer.database.windows.net,1433;Initial Catalog=$SqlDatabase;Persist Security Info=False;User ID=$SqlAdminUser;Password=$SqlAdminPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# Salvar em arquivo seguro
$ConnectionString | Out-File -FilePath "connection-string.txt"
```

### 9. Build da Imagem Docker

```powershell
$imageName = "$ContainerRegistry.azurecr.io/$AppName:latest"

docker build -t $imageName -f Dockerfile .
```

### 10. Login no Container Registry

```powershell
az acr login --name $ContainerRegistry
```

### 11. Push da Imagem

```powershell
docker push $imageName
```

### 12. Obter Credenciais do ACR

```powershell
$acrCreds = az acr credential show --name $ContainerRegistry | ConvertFrom-Json
$acrServer = "$ContainerRegistry.azurecr.io"
$acrUser = $acrCreds.username
$acrPassword = $acrCreds.passwords[0].value
```

### 13. Criar Container Apps Environment

```powershell
$envName = "$AppName-env"

az containerapp env create `
  --name $envName `
  --resource-group $ResourceGroup `
  --location $Location
```

### 14. Criar Container App

```powershell
az containerapp create `
  --name $AppName `
  --resource-group $ResourceGroup `
  --environment $envName `
  --image $imageName `
  --target-port 8080 `
  --ingress external `
  --registry-server $acrServer `
  --registry-username $acrUser `
  --registry-password $acrPassword `
  --cpu 0.5 `
  --memory 1.0Gi `
  --min-replicas 1 `
  --max-replicas 3 `
  --env-vars "ConnectionStrings__DefaultConnection=$ConnectionString" "ASPNETCORE_ENVIRONMENT=Production"
```

### 15. Obter URL Pública

```powershell
$app = az containerapp show `
  --name $AppName `
  --resource-group $ResourceGroup | ConvertFrom-Json

$appUrl = "https://$($app.properties.configuration.ingress.fqdn)"

Write-Host "✅ Aplicação publicada em: $appUrl" -ForegroundColor Green
Write-Host "📖 Swagger: $appUrl/swagger" -ForegroundColor Cyan
Write-Host "💚 Health: $appUrl/health" -ForegroundColor Cyan
```

---

## 🔄 Atualizar Aplicação (Redeploy)

Após fazer mudanças no código:

```powershell
# 1. Rebuild da imagem
$imageName = "acrdesenvolvimento.azurecr.io/desenvolvimento-pessoas:latest"
docker build -t $imageName -f Dockerfile .

# 2. Login no ACR
az acr login --name acrdesenvolvimento

# 3. Push nova imagem
docker push $imageName

# 4. Atualizar Container App
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --image $imageName
```

**Tempo de atualização:** 2-3 minutos

---

## 🔧 Configurar Variáveis de Ambiente Adicionais

### OpenAI (para chat AI):
```powershell
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --set-env-vars `
	"OpenAI__ApiKey=sk-..." `
	"OpenAI__Model=gpt-4"
```

### Stripe (para pagamentos):
```powershell
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --set-env-vars `
	"Stripe__SecretKey=sk_live_..." `
	"Stripe__PublishableKey=pk_live_..."
```

### Azure Blob Storage (para vídeos):
```powershell
# Primeiro criar o Storage Account
az storage account create `
  --name stdesenvolvimento `
  --resource-group rg-desenvolvimento-pessoas `
  --location brazilsouth `
  --sku Standard_LRS

# Obter connection string
$storageConn = az storage account show-connection-string `
  --name stdesenvolvimento `
  --resource-group rg-desenvolvimento-pessoas `
  --query connectionString -o tsv

# Criar container de vídeos
az storage container create `
  --name videos `
  --account-name stdesenvolvimento `
  --public-access blob

# Atualizar app
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --set-env-vars `
	"Azure__BlobStorage__ConnectionString=$storageConn" `
	"Azure__BlobStorage__ContainerName=videos"
```

---

## 📊 Monitoramento e Logs

### Ver Logs em Tempo Real
```powershell
az containerapp logs show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --follow
```

### Ver Logs das Últimas Horas
```powershell
az containerapp logs show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --tail 100
```

### Ver Métricas de CPU e Memória
```powershell
az monitor metrics list `
  --resource "/subscriptions/{subscription-id}/resourceGroups/rg-desenvolvimento-pessoas/providers/Microsoft.App/containerApps/desenvolvimento-pessoas" `
  --metric-names "CpuPercentage,MemoryPercentage"
```

### Portal Azure - Log Analytics
1. Acesse: https://portal.azure.com
2. Resource Groups → `rg-desenvolvimento-pessoas`
3. `desenvolvimento-pessoas` (Container App)
4. **Logs** (menu lateral)
5. Execute queries:

```kql
// Últimos erros
ContainerAppConsoleLogs_CL
| where Log_s contains "error" or Log_s contains "exception"
| order by TimeGenerated desc
| take 50

// Requisições por endpoint
ContainerAppConsoleLogs_CL
| where Log_s contains "HTTP"
| summarize count() by bin(TimeGenerated, 5m)
```

---

## 🌐 Configurar Domínio Personalizado

### Pré-requisito: Ter um domínio registrado (ex: meusite.com.br)

### 1. Adicionar Domínio Personalizado

```powershell
az containerapp hostname add `
  --hostname "api.meusite.com.br" `
  --resource-group rg-desenvolvimento-pessoas `
  --name desenvolvimento-pessoas
```

### 2. Obter Validation Code (para DNS)
```powershell
az containerapp hostname list `
  --resource-group rg-desenvolvimento-pessoas `
  --name desenvolvimento-pessoas
```

### 3. Configurar DNS no seu Provedor

Adicione os registros DNS:

**Registro CNAME:**
- Host: `api` (ou `@` para raiz)
- Tipo: `CNAME`
- Valor: `desenvolvimento-pessoas.{random}.brazilsouth.azurecontainerapps.io`

**Registro TXT (validação):**
- Host: `asuid.api`
- Tipo: `TXT`
- Valor: `{validation-code-from-step-2}`

### 4. Vincular Certificado SSL (Automático)
```powershell
az containerapp hostname bind `
  --hostname "api.meusite.com.br" `
  --resource-group rg-desenvolvimento-pessoas `
  --name desenvolvimento-pessoas `
  --validation-method CNAME
```

Azure irá provisionar certificado SSL gerenciado automaticamente.

---

## 💰 Gerenciar Custos

### Ver Custos Atuais
```powershell
az consumption usage list `
  --start-date (Get-Date).AddDays(-30).ToString("yyyy-MM-dd") `
  --end-date (Get-Date).ToString("yyyy-MM-dd") `
  | ConvertFrom-Json `
  | Group-Object meterCategory `
  | Select-Object Name, Count
```

### Configurar Budget Alert
```powershell
# Via Portal: Cost Management + Billing → Budgets → Create Budget
# Exemplo: Alerta quando custo mensal atingir $20
```

### Reduzir Custos

**1. Reduzir réplicas mínimas:**
```powershell
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --min-replicas 0  # Escala para 0 quando sem uso (cold start ~5s)
```

**2. Usar SQL Database menor (desenvolvimento):**
```powershell
az sql db update `
  --resource-group rg-desenvolvimento-pessoas `
  --server sql-desenvolvimento-pessoas `
  --name DesenvPessoasDb `
  --service-objective Basic  # Mais barato
```

**3. Pausar SQL Database quando não usado:**
```powershell
az sql db pause `
  --resource-group rg-desenvolvimento-pessoas `
  --server sql-desenvolvimento-pessoas `
  --name DesenvPessoasDb
```

**4. Deletar recursos temporariamente:**
```powershell
# Deletar Container App (mantém dados do SQL)
az containerapp delete `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --yes

# Recriar quando necessário
```

---

## 🗑️ Remover Recursos (Cleanup)

### Deletar Resource Group Completo
```powershell
az group delete `
  --name rg-desenvolvimento-pessoas `
  --yes `
  --no-wait
```

⚠️ **ATENÇÃO:** Isto deleta TUDO (App, Database, Registry). Não é reversível!

### Deletar Apenas Alguns Recursos
```powershell
# Apenas Container App
az containerapp delete --name desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --yes

# Apenas SQL Database (mantém servidor)
az sql db delete --name DesenvPessoasDb --server sql-desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --yes

# Apenas SQL Server completo
az sql server delete --name sql-desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --yes
```

---

## 🐛 Troubleshooting

### ❌ Erro: "Image not found"
**Solução:**
```powershell
# Verificar se imagem existe no ACR
az acr repository list --name acrdesenvolvimento

# Re-push da imagem
docker push acrdesenvolvimento.azurecr.io/desenvolvimento-pessoas:latest
```

### ❌ Erro: "Connection to SQL Database failed"
**Solução:**
```powershell
# Verificar firewall do SQL
az sql server firewall-rule list `
  --server sql-desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas

# Adicionar regra para Azure Services
az sql server firewall-rule create `
  --resource-group rg-desenvolvimento-pessoas `
  --server sql-desenvolvimento-pessoas `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0
```

### ❌ Erro: "Container is crashing"
**Solução:**
```powershell
# Ver logs detalhados
az containerapp logs show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --tail 200

# Verificar variáveis de ambiente
az containerapp show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --query "properties.template.containers[0].env"
```

### ❌ Erro: "Unauthorized" no ACR
**Solução:**
```powershell
# Re-login
az acr login --name acrdesenvolvimento

# Ou usar credenciais admin
$creds = az acr credential show --name acrdesenvolvimento | ConvertFrom-Json
docker login acrdesenvolvimento.azurecr.io -u $creds.username -p $creds.passwords[0].value
```

### ❌ Aplicação retorna 502/503
**Causas comuns:**
1. Porta incorreta no Dockerfile (deve ser 8080 por padrão no Container Apps)
2. App não está escutando em `0.0.0.0` (deve usar `http://+:8080`)
3. Startup lento (aumentar timeout)

**Solução:**
```powershell
# Verificar configuração de porta
az containerapp show `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --query "properties.template.containers[0].{image:image,port:targetPort}"

# Atualizar se necessário
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --target-port 8080
```

---

## 📚 Recursos Adicionais

- **Portal Azure:** https://portal.azure.com
- **Documentação Container Apps:** https://learn.microsoft.com/azure/container-apps/
- **Documentação SQL Database:** https://learn.microsoft.com/azure/azure-sql/
- **Preços:** https://azure.microsoft.com/pricing/calculator/
- **Status Azure:** https://status.azure.com/

---

## 🎓 Próximos Passos

1. ✅ **CI/CD com GitHub Actions** - Automatizar deploy a cada commit
2. ✅ **Application Insights** - Telemetria e métricas avançadas
3. ✅ **Azure Key Vault** - Armazenar segredos (senhas, API keys)
4. ✅ **CDN** - Acelerar entrega de conteúdo estático
5. ✅ **Backup Automatizado** - Garantir recuperação de dados

---

**Criado por:** Script de Deploy Automatizado  
**Última atualização:** 2025-06-01  
**Versão:** 1.0
