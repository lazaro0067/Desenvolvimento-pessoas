# 🌐 Guia de Acesso - Plataforma Desenvolvimento de Pessoas

Este documento contém todas as URLs e informações de acesso para a plataforma.

---

## 🏠 AMBIENTE LOCAL (Desenvolvimento)

### 🚀 Iniciar Aplicação Localmente

```powershell
# No diretório do projeto
cd publish\api
dotnet Desenvolvimento.Api.dll --urls "http://localhost:5000"
```

### 📍 URLs Locais

| Recurso | URL | Descrição |
|---------|-----|-----------|
| **Health Check** | http://localhost:5000/health | Verifica se API está rodando |
| **Swagger UI** | http://localhost:5000/swagger | Documentação interativa da API |
| **OpenAPI JSON** | http://localhost:5000/swagger/v1/swagger.json | Especificação OpenAPI |
| **Endpoint Base** | http://localhost:5000/api | Base URL para todos os endpoints |

### 🔑 Credenciais Locais (Desenvolvimento)

**Banco de Dados:**
- **Connection String:** `Server=(localdb)\\mssqllocaldb;Database=DesenvPessoasDb;Trusted_Connection=True;`

**Usuário Master Padrão:**
- **Email:** `admin@exemplo.com`
- **Senha:** `Admin@123456`

---

## ☁️ AMBIENTE AZURE (Produção)

### 🚀 Deploy e Acesso

Para fazer o primeiro deploy no Azure, siga o guia: **[QUICKSTART_DEPLOY.md](QUICKSTART_DEPLOY.md)**

**Comando rápido:**
```powershell
.\deploy-azure.ps1
```

### 📍 URLs Públicas (Após Deploy)

| Recurso | URL | Descrição |
|---------|-----|-----------|
| **Health Check** | `https://{app-url}/health` | Verifica se API está rodando |
| **Swagger UI** | `https://{app-url}/swagger` | Documentação interativa da API |
| **OpenAPI JSON** | `https://{app-url}/swagger/v1/swagger.json` | Especificação OpenAPI |
| **Endpoint Base** | `https://{app-url}/api` | Base URL para todos os endpoints |

**⚠️ Nota:** Após o deploy, o script `deploy-azure.ps1` mostrará a URL completa. Substitua `{app-url}` pela URL real, exemplo:
```
https://desenvolvimento-pessoas--abc123.brazilsouth-01.azurecontainerapps.io
```

### 🔑 Credenciais Azure (Geradas no Deploy)

As credenciais são geradas automaticamente pelo script e salvas em: **`azure-deploy-info.json`**

**Banco de Dados Azure SQL:**
- **Server:** `sql-desenvolvimento-pessoas.database.windows.net`
- **Database:** `DesenvPessoasDb`
- **User:** `admindesenv`
- **Password:** *(gerada automaticamente - veja azure-deploy-info.json)*
- **Connection String:** *(gerada automaticamente - veja azure-deploy-info.json)*

**⚠️ IMPORTANTE:** Faça backup do arquivo `azure-deploy-info.json` em local seguro!

---

## 📖 DOCUMENTAÇÃO DA API

### Endpoints Principais

#### 👤 **Usuários e Autenticação**
- `GET /api/users` - Listar usuários
- `POST /api/admin/ensure` - Criar usuário Master inicial

#### 📋 **Perfis de Desenvolvimento**
- `GET /api/profiles` - Listar perfis
- `POST /api/profiles` - Criar perfil
- `GET /api/profiles/{id}` - Buscar perfil por ID
- `PUT /api/profiles/{id}` - Atualizar perfil
- `DELETE /api/profiles/{id}` - Deletar perfil

#### 📄 **Currículos**
- `GET /api/curriculums` - Listar currículos
- `POST /api/curriculums` - Criar currículo

#### 🎯 **Avaliação DISC**
- `POST /api/disc/submit` - Submeter respostas DISC e obter resultado

#### 📚 **Cursos e Trilhas**
- `GET /api/courses` - Listar cursos
- `POST /api/courses` - Criar curso
- `GET /api/tracks` - Listar trilhas de conhecimento
- `POST /api/tracks` - Criar trilha

#### 💬 **Chat AI (Consultoria Virtual)**
- `POST /api/chat` - Enviar mensagem para agente AI
- `GET /api/chat/history/{userId}` - Histórico de conversas

#### 💳 **Pagamentos e Assinaturas**
- `POST /api/checkout` - Criar sessão de checkout
- `POST /api/subscriptions` - Criar assinatura
- `GET /api/subscriptions/{userId}` - Buscar assinatura de usuário

#### 🔐 **Permissões (Master)**
- `POST /api/permissions` - Atribuir permissão a usuário
- `GET /api/permissions/{userId}` - Listar permissões de usuário

#### 📱 **Compartilhamento Social**
- `POST /api/share` - Registrar compartilhamento
- `GET /api/share/{userId}` - Histórico de compartilhamentos

### Exemplo de Requisição (cURL)

```bash
# Health Check
curl https://seu-app-url/health

# Criar usuário Master
curl -X POST https://seu-app-url/api/admin/ensure \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@exemplo.com","password":"Admin@123456"}'

# Enviar mensagem para chat AI
curl -X POST https://seu-app-url/api/chat \
  -H "Content-Type: application/json" \
  -d '{"userId":"user-123","message":"Como melhorar minha comunicação?"}'

# Submeter avaliação DISC
curl -X POST https://seu-app-url/api/disc/submit \
  -H "Content-Type: application/json" \
  -d '{"userId":"user-123","answers":{"d1":4,"i1":3,"s1":2,"c1":5}}'
```

### Exemplo de Requisição (PowerShell)

```powershell
$baseUrl = "https://seu-app-url"  # Trocar pela URL real

# Health Check
Invoke-RestMethod -Uri "$baseUrl/health"

# Criar usuário Master
$body = @{
	email = "admin@exemplo.com"
	password = "Admin@123456"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$baseUrl/api/admin/ensure" -Method POST -Body $body -ContentType "application/json"

# Chat AI
$chatBody = @{
	userId = "user-123"
	message = "Como desenvolver liderança?"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$baseUrl/api/chat" -Method POST -Body $chatBody -ContentType "application/json"
```

---

## 🔧 GERENCIAMENTO

### Portal Azure
- **URL:** https://portal.azure.com
- **Resource Group:** `rg-desenvolvimento-pessoas`
- **Container App:** `desenvolvimento-pessoas`

### Azure CLI (Comandos Úteis)

```powershell
# Ver logs em tempo real
az containerapp logs show --name desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --follow

# Atualizar variável de ambiente
az containerapp update --name desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --set-env-vars "OpenAI__ApiKey=sk-nova-chave"

# Escalar réplicas
az containerapp update --name desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --min-replicas 2 --max-replicas 5

# Ver status
az containerapp show --name desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --query "properties.runningStatus"
```

### Atualizar Aplicação (Redeploy)

```powershell
# Rebuild e push
$imageName = "acrdesenvolvimento.azurecr.io/desenvolvimento-pessoas:latest"
docker build -t $imageName -f Dockerfile .
az acr login --name acrdesenvolvimento
docker push $imageName

# Atualizar Container App
az containerapp update --name desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --image $imageName
```

---

## 📊 MONITORAMENTO

### Dashboards e Logs
- **Application Insights:** *(configurar conforme [MONITORING.md](MONITORING.md))*
- **Log Analytics:** Portal Azure → Container App → Logs
- **Metrics:** Portal Azure → Container App → Metrics

### Health Check Automatizado

```powershell
# Script de monitoramento (salvar como monitor-health.ps1)
$url = "https://seu-app-url/health"
$interval = 60  # segundos

while ($true) {
	try {
		$response = Invoke-RestMethod -Uri $url -TimeoutSec 5
		if ($response.status -eq "ok") {
			Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✅ Status: OK" -ForegroundColor Green
		} else {
			Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ⚠️  Status: $($response.status)" -ForegroundColor Yellow
		}
	} catch {
		Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ❌ ERRO: $($_.Exception.Message)" -ForegroundColor Red
	}
	Start-Sleep -Seconds $interval
}
```

---

## 🆘 SUPORTE E TROUBLESHOOTING

### Documentação Completa
- **Setup Azure:** [AZURE_SETUP.md](AZURE_SETUP.md)
- **Deploy Rápido:** [QUICKSTART_DEPLOY.md](QUICKSTART_DEPLOY.md)
- **Deploy Detalhado:** [DEPLOY_AZURE.md](DEPLOY_AZURE.md)
- **Monitoramento:** [MONITORING.md](MONITORING.md)
- **Documentação Técnica:** [PROJETO.md](PROJETO.md)

### Problemas Comuns

❌ **"Esta localhost página não pode ser encontrada" (Erro 404)**
- **Causa:** Aplicação não está rodando localmente
- **Solução:**
  ```powershell
  cd publish\api
  dotnet Desenvolvimento.Api.dll --urls "http://localhost:5000"
  ```

❌ **Azure: "502/503 Service Unavailable"**
- **Causa:** Container não iniciou corretamente
- **Solução:**
  ```powershell
  # Ver logs
  az containerapp logs show --name desenvolvimento-pessoas --resource-group rg-desenvolvimento-pessoas --tail 100
  ```

❌ **"Connection to SQL Database failed"**
- **Causa:** Firewall bloqueando Azure Services
- **Solução:**
  ```powershell
  az sql server firewall-rule create --resource-group rg-desenvolvimento-pessoas --server sql-desenvolvimento-pessoas --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
  ```

### Links de Suporte
- **Azure Status:** https://status.azure.com/
- **Stack Overflow (Azure):** https://stackoverflow.com/questions/tagged/azure
- **Microsoft Learn:** https://learn.microsoft.com/azure/

---

## 📝 NOTAS IMPORTANTES

1. **Segurança:**
   - Nunca commitar `azure-deploy-info.json` no Git (já está no .gitignore)
   - Usar Azure Key Vault para produção real
   - Implementar autenticação JWT para endpoints críticos

2. **Performance:**
   - Cold start pode levar 3-5 segundos se min-replicas=0
   - Aumentar réplicas para aplicações de alto tráfego
   - Considerar Azure CDN para conteúdo estático

3. **Custos:**
   - Monitorar uso mensal no Portal Azure → Cost Management
   - Free tier cobre desenvolvimento ($200 em 30 dias)
   - Produção: ~$15-20/mês com tráfego baixo/médio

4. **Backup:**
   - Azure SQL faz backup automático (7 dias de retenção no Basic tier)
   - Para produção, aumentar retenção: 35 dias (tier Standard)
   - Exportar .bacpac periodicamente para backup local

---

## ✅ CHECKLIST DE VALIDAÇÃO

### Local
- [ ] `dotnet --version` retorna .NET 10.x
- [ ] `http://localhost:5000/health` retorna `{"status":"ok"}`
- [ ] `http://localhost:5000/swagger` mostra documentação

### Azure
- [ ] Deploy executado com sucesso
- [ ] URL pública acessível
- [ ] `/health` retorna OK
- [ ] `/swagger` mostra documentação
- [ ] Credenciais salvas em `azure-deploy-info.json`
- [ ] Banco de dados conectado e funcional

---

**Última atualização:** 2025-06-01  
**Versão:** 2.0 (Incluindo Azure)
