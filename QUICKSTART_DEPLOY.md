# 🚀 GUIA RÁPIDO - Primeiro Deploy no Azure

## ⏱️ Tempo Estimado
- **Total:** 15-20 minutos
- **Setup Azure:** 5 minutos
- **Deploy:** 10-15 minutos

---

## 📋 PRÉ-REQUISITOS (Verificar Antes de Começar)

### ✅ Checklist Obrigatória

- [ ] **Conta Azure criada** (veja [AZURE_SETUP.md](AZURE_SETUP.md))
  - Com $200 de crédito gratuito OU cartão de crédito válido

- [ ] **Azure CLI instalado**
  ```powershell
  az --version  # Deve retornar versão
  ```

- [ ] **Docker Desktop instalado e rodando**
  ```powershell
  docker --version  # Deve retornar versão
  docker ps  # Deve listar containers (pode estar vazio)
  ```

- [ ] **Login no Azure feito**
  ```powershell
  az login
  az account show  # Deve mostrar sua conta
  ```

- [ ] **Aplicação testada localmente**
  - ✅ `http://localhost:5000/health` retorna `{"status":"ok"}`
  - ✅ `http://localhost:5000/swagger` abre documentação

---

## 🎯 OPÇÃO 1: Deploy Automatizado (RECOMENDADO)

### Passo Único

```powershell
# No diretório raiz do projeto (C:\Users\Lázaro\source\repos\Desenvolvimento de pessoas\)
.\deploy-azure.ps1
```

**O que acontecerá:**
1. ✅ Validará sua autenticação Azure
2. ✅ Mostrará resumo da configuração
3. ❓ Perguntará se deseja continuar (digite **S** e Enter)
4. 🔄 Criará todos os recursos Azure (~10 min):
   - Resource Group
   - Container Registry
   - SQL Server + Database
   - Container Apps Environment
   - Container App (sua aplicação)
5. 🎉 Mostrará URL pública ao final

**Exemplo de saída final:**
```
╔══════════════════════════════════════════════════════════╗
║              DEPLOY CONCLUÍDO COM SUCESSO!               ║
╚══════════════════════════════════════════════════════════╝

📍 URL da Aplicação:
   https://desenvolvimento-pessoas--abc123.brazilsouth-01.azurecontainerapps.io

📍 Swagger Documentation:
   https://desenvolvimento-pessoas--abc123.brazilsouth-01.azurecontainerapps.io/swagger

📦 Banco de Dados Azure SQL:
   Server: sql-desenvolvimento-pessoas.database.windows.net
   User: admindesenv
   Password: P@ssw0rd!Abc123XYZ
   ⚠️  SALVE ESTAS INFORMAÇÕES EM LOCAL SEGURO!
```

### ⚠️ IMPORTANTE: Salvar Credenciais

O script cria o arquivo `azure-deploy-info.json` com todas as informações. **Faça backup deste arquivo!**

---

## 🎯 OPÇÃO 2: Deploy Manual (Educacional)

Veja o guia completo em: [DEPLOY_AZURE.md](DEPLOY_AZURE.md)

### Resumo dos Comandos

```powershell
# 1. Definir variáveis
$ResourceGroup = "rg-desenvolvimento-pessoas"
$AppName = "desenvolvimento-pessoas"
$Location = "brazilsouth"

# 2. Criar Resource Group
az group create --name $ResourceGroup --location $Location

# 3. Criar Container Registry
az acr create --name acrdesenvolvimento --resource-group $ResourceGroup --sku Basic --admin-enabled true

# 4. Build e Push Docker
$imageName = "acrdesenvolvimento.azurecr.io/desenvolvimento-pessoas:latest"
docker build -t $imageName -f Dockerfile .
az acr login --name acrdesenvolvimento
docker push $imageName

# 5. Criar SQL Server e Database
az sql server create --name sql-desenvolvimento-pessoas --resource-group $ResourceGroup --location $Location --admin-user admindesenv --admin-password "SuaSenhaForte123!@#"
az sql server firewall-rule create --resource-group $ResourceGroup --server sql-desenvolvimento-pessoas --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
az sql db create --resource-group $ResourceGroup --server sql-desenvolvimento-pessoas --name DesenvPessoasDb --service-objective Basic

# 6. Criar Container Apps Environment
az containerapp env create --name desenvolvimento-pessoas-env --resource-group $ResourceGroup --location $Location

# 7. Deploy Container App
$connString = "Server=tcp:sql-desenvolvimento-pessoas.database.windows.net,1433;Initial Catalog=DesenvPessoasDb;User ID=admindesenv;Password=SuaSenhaForte123!@#;Encrypt=True;"
az containerapp create --name $AppName --resource-group $ResourceGroup --environment desenvolvimento-pessoas-env --image $imageName --target-port 8080 --ingress external --registry-server acrdesenvolvimento.azurecr.io --cpu 0.5 --memory 1.0Gi --min-replicas 1 --max-replicas 3 --env-vars "ConnectionStrings__DefaultConnection=$connString" "ASPNETCORE_ENVIRONMENT=Production"

# 8. Obter URL
$app = az containerapp show --name $AppName --resource-group $ResourceGroup | ConvertFrom-Json
Write-Host "✅ URL: https://$($app.properties.configuration.ingress.fqdn)"
```

---

## 🧪 VALIDAR DEPLOY

Após o deploy, validar:

### 1. Health Check
```powershell
$url = "https://SEU-APP-URL-AQUI"  # Trocar pela URL real

# Testar health
Invoke-RestMethod -Uri "$url/health"
# Esperado: { "status": "ok" }
```

### 2. Swagger
Abrir no navegador:
```
https://SEU-APP-URL-AQUI/swagger
```

Deve mostrar a documentação interativa da API.

### 3. Testar Endpoint de Admin
```powershell
# Criar usuário Master inicial
$body = @{
	email = "admin@exemplo.com"
	password = "Admin@123456"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$url/api/admin/ensure" -Method POST -Body $body -ContentType "application/json"
# Esperado: { "message": "Master user created" }
```

---

## ⚠️ PROBLEMAS COMUNS

### ❌ "Docker não está rodando"
**Solução:**
1. Abrir Docker Desktop
2. Aguardar inicializar completamente (ícone fica verde)
3. Testar: `docker ps`

### ❌ "Azure CLI não encontrado"
**Solução:**
```powershell
# Instalar
winget install -e --id Microsoft.AzureCLI

# Reiniciar terminal
# Testar
az --version
```

### ❌ "Access denied" ao fazer `az login`
**Solução:**
- Verificar se você tem permissão de Owner/Contributor na subscription
- Tentar fazer login via navegador: `az login --use-device-code`

### ❌ Deploy falha com "Image not found"
**Solução:**
```powershell
# Re-push da imagem
az acr login --name acrdesenvolvimento
docker push acrdesenvolvimento.azurecr.io/desenvolvimento-pessoas:latest

# Atualizar Container App
az containerapp update --name desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --image acrdesenvolvimento.azurecr.io/desenvolvimento-pessoas:latest
```

### ❌ App retorna 502/503
**Solução:**
```powershell
# Ver logs
az containerapp logs show --name desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --tail 100

# Verificar variáveis de ambiente
az containerapp show --name desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --query "properties.template.containers[0].env"
```

**Mais soluções:** Veja [DEPLOY_AZURE.md](DEPLOY_AZURE.md) seção Troubleshooting

---

## 🔄 REDEPLOYAR (Após Mudanças no Código)

```powershell
# Rebuild e push
$imageName = "acrdesenvolvimento.azurecr.io/desenvolvimento-pessoas:latest"
docker build -t $imageName -f Dockerfile .
az acr login --name acrdesenvolvimento
docker push $imageName

# Atualizar Container App
az containerapp update `
  --name desenvolvimento-pessoas `
  --resource-group rg-desenvolvimento-pessoas `
  --image $imageName

# Aguardar 2-3 minutos e testar
```

---

## 💰 CUSTOS ESTIMADOS

### Durante Free Trial (30 dias com $200)
- ✅ **GRÁTIS** - Coberto pelo crédito gratuito

### Após Free Trial
| Recurso | Custo Mensal (USD) |
|---------|-------------------|
| Azure Container Apps | $5-10 |
| Azure SQL Database (Basic) | $5 |
| Azure Container Registry | $5 |
| **TOTAL** | **$15-20** |

**Nota:** Valores para tráfego baixo/médio (~10k requisições/dia)

### Reduzir Custos
```powershell
# Escalar para 0 réplicas quando ocioso (cold start ~5s)
az containerapp update --name desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --min-replicas 0

# Pausar SQL Database quando não usar
az sql db pause --resource-group rg-desenvolvimento-pessoas --server sql-desenvolvimento-pessoas --name DesenvPessoasDb
```

---

## 🗑️ REMOVER TUDO (Cleanup)

```powershell
# CUIDADO: Isto deleta TUDO permanentemente!
az group delete --name rg-desenvolvimento-pessoas --yes --no-wait
```

---

## 📚 PRÓXIMOS PASSOS

1. ✅ **Testar a aplicação** em `https://seu-app-url/swagger`
2. ✅ **Configurar domínio personalizado** (opcional) - Ver [DEPLOY_AZURE.md](DEPLOY_AZURE.md)
3. ✅ **Adicionar API keys** (OpenAI, Stripe) - Ver [DEPLOY_AZURE.md](DEPLOY_AZURE.md) seção "Configurar Variáveis de Ambiente"
4. ✅ **Configurar CI/CD** com GitHub Actions (opcional)
5. ✅ **Habilitar Application Insights** - Ver [MONITORING.md](MONITORING.md)
6. ✅ **Configurar alertas** de erro/performance - Ver [MONITORING.md](MONITORING.md)

---

## 📞 SUPORTE

- **Documentação Completa:** [DEPLOY_AZURE.md](DEPLOY_AZURE.md)
- **Monitoramento:** [MONITORING.md](MONITORING.md)
- **Setup Inicial:** [AZURE_SETUP.md](AZURE_SETUP.md)
- **Azure Status:** https://status.azure.com/
- **Azure Support:** https://portal.azure.com (se tiver plano de suporte)

---

## ✅ CHECKLIST FINAL

Após deploy bem-sucedido:

- [ ] URL pública funcionando
- [ ] `/health` retorna OK
- [ ] `/swagger` mostra documentação
- [ ] Credenciais do banco salvas em local seguro
- [ ] `azure-deploy-info.json` com backup
- [ ] Alertas configurados (ver MONITORING.md)
- [ ] Domínio personalizado configurado (opcional)

---

**🎉 Parabéns! Sua plataforma está online e acessível pela internet!**

**Criado por:** Guia de Quick Start  
**Última atualização:** 2025-06-01  
**Versão:** 1.0
