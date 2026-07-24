# 🚀 Script Automatizado de Deploy no Azure
# Plataforma Desenvolvimento de Pessoas
# Uso: .\deploy-azure.ps1

param(
	[string]$ResourceGroup = "rg-desenvolvimento-pessoas",
	[string]$Location = "brazilsouth",
	[string]$AppName = "desenvolvimento-pessoas",
	[string]$SqlServer = "sql-desenvolvimento-pessoas",
	[string]$SqlDatabase = "DesenvPessoasDb",
	[string]$SqlAdminUser = "admindesenv",
	[string]$ContainerRegistry = "acrdesenvolvimento",
	[switch]$SkipBuild,
	[switch]$SkipDatabase
)

# Cores para output
function Write-Step { param($msg) Write-Host "► $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Error { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "ℹ $msg" -ForegroundColor Yellow }

# Banner
Write-Host @"
╔══════════════════════════════════════════════════════════╗
║   AZURE DEPLOYMENT - Desenvolvimento de Pessoas          ║
║   Script automatizado de publicação                      ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

# Validar Azure CLI
Write-Step "Validando Azure CLI..."
try {
	$azVersion = az --version | Select-Object -First 1
	Write-Success "Azure CLI instalado: $azVersion"
} catch {
	Write-Error "Azure CLI não encontrado!"
	Write-Info "Instale com: winget install -e --id Microsoft.AzureCLI"
	exit 1
}

# Verificar login
Write-Step "Verificando autenticação Azure..."
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
	Write-Info "Fazendo login no Azure..."
	az login
	$account = az account show | ConvertFrom-Json
}
Write-Success "Autenticado como: $($account.user.name)"
Write-Info "Subscription: $($account.name) ($($account.id))"

# Confirmar com usuário
Write-Host ""
Write-Host "Configuração do Deploy:" -ForegroundColor Yellow
Write-Host "  Resource Group: $ResourceGroup"
Write-Host "  Localização: $Location (Brasil Sul)"
Write-Host "  App Name: $AppName"
Write-Host "  SQL Server: $SqlServer"
Write-Host "  SQL Database: $SqlDatabase"
Write-Host "  Container Registry: $ContainerRegistry"
Write-Host ""
$confirm = Read-Host "Continuar com o deploy? (S/N)"
if ($confirm -ne "S" -and $confirm -ne "s") {
	Write-Info "Deploy cancelado pelo usuário."
	exit 0
}

# 1. Criar Resource Group
Write-Step "Criando Resource Group..."
az group create --name $ResourceGroup --location $Location --output none
Write-Success "Resource Group criado"

# 2. Criar Azure Container Registry
Write-Step "Criando Azure Container Registry..."
$acrExists = az acr show --name $ContainerRegistry --resource-group $ResourceGroup 2>$null
if (-not $acrExists) {
	az acr create `
		--resource-group $ResourceGroup `
		--name $ContainerRegistry `
		--sku Basic `
		--admin-enabled true `
		--output none
	Write-Success "Container Registry criado"
} else {
	Write-Info "Container Registry já existe, reutilizando..."
}

# 3. Criar SQL Server e Database (se não skipped)
if (-not $SkipDatabase) {
	Write-Step "Criando Azure SQL Server e Database..."

	# Gerar senha aleatória segura
	$SqlAdminPassword = -join ((48..57) + (65..90) + (97..122) + (33, 35, 36, 37, 38, 42, 43, 45, 61, 63, 64) | Get-Random -Count 16 | ForEach-Object {[char]$_})
	$SqlAdminPassword = "P@ssw0rd!" + $SqlAdminPassword  # Garantir complexidade

	Write-Info "SQL Admin User: $SqlAdminUser"
	Write-Info "SQL Admin Password: $SqlAdminPassword"
	Write-Host "⚠️  SALVE ESTAS CREDENCIAIS EM LOCAL SEGURO!" -ForegroundColor Red

	# Criar SQL Server
	$sqlServerExists = az sql server show --name $SqlServer --resource-group $ResourceGroup 2>$null
	if (-not $sqlServerExists) {
		az sql server create `
			--name $SqlServer `
			--resource-group $ResourceGroup `
			--location $Location `
			--admin-user $SqlAdminUser `
			--admin-password $SqlAdminPassword `
			--output none
		Write-Success "SQL Server criado"

		# Configurar firewall para permitir Azure Services
		Write-Step "Configurando firewall do SQL Server..."
		az sql server firewall-rule create `
			--resource-group $ResourceGroup `
			--server $SqlServer `
			--name AllowAzureServices `
			--start-ip-address 0.0.0.0 `
			--end-ip-address 0.0.0.0 `
			--output none
		Write-Success "Firewall configurado"
	} else {
		Write-Info "SQL Server já existe, reutilizando..."
	}

	# Criar Database
	$dbExists = az sql db show --name $SqlDatabase --server $SqlServer --resource-group $ResourceGroup 2>$null
	if (-not $dbExists) {
		az sql db create `
			--resource-group $ResourceGroup `
			--server $SqlServer `
			--name $SqlDatabase `
			--service-objective Basic `
			--backup-storage-redundancy Local `
			--output none
		Write-Success "Database criado"
	} else {
		Write-Info "Database já existe, reutilizando..."
	}

	# Criar connection string
	$ConnectionString = "Server=tcp:$SqlServer.database.windows.net,1433;Initial Catalog=$SqlDatabase;Persist Security Info=False;User ID=$SqlAdminUser;Password=$SqlAdminPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

	Write-Info "Connection String gerada (será configurada como variável de ambiente)"
} else {
	Write-Info "Criação de database ignorada (--SkipDatabase)"
}

# 4. Build Docker Image (se não skipped)
if (-not $SkipBuild) {
	Write-Step "Fazendo build da imagem Docker..."
	$imageName = "$ContainerRegistry.azurecr.io/$AppName`:latest"

	docker build -t $imageName -f Dockerfile .
	if ($LASTEXITCODE -ne 0) {
		Write-Error "Falha no build da imagem Docker"
		exit 1
	}
	Write-Success "Imagem Docker criada: $imageName"
} else {
	Write-Info "Build da imagem ignorado (--SkipBuild)"
	$imageName = "$ContainerRegistry.azurecr.io/$AppName`:latest"
}

# 5. Push da imagem para ACR
Write-Step "Enviando imagem para Azure Container Registry..."
az acr login --name $ContainerRegistry --output none
docker push $imageName
if ($LASTEXITCODE -ne 0) {
	Write-Error "Falha ao enviar imagem para Azure Container Registry"
	exit 1
}
Write-Success "Imagem enviada para ACR"

# 6. Criar Azure Container Apps Environment
Write-Step "Criando Container Apps Environment..."
$envName = "$AppName-env"
$envExists = az containerapp env show --name $envName --resource-group $ResourceGroup 2>$null
if (-not $envExists) {
	az containerapp env create `
		--name $envName `
		--resource-group $ResourceGroup `
		--location $Location `
		--output none
	Write-Success "Container Apps Environment criado"
} else {
	Write-Info "Container Apps Environment já existe"
}

# 7. Criar/Atualizar Container App
Write-Step "Criando/Atualizando Container App..."

# Obter credenciais do ACR
$acrCreds = az acr credential show --name $ContainerRegistry | ConvertFrom-Json
$acrServer = "$ContainerRegistry.azurecr.io"
$acrUser = $acrCreds.username
$acrPassword = $acrCreds.passwords[0].value

# Preparar variáveis de ambiente
$envVars = @()
if ($ConnectionString) {
	$envVars += "ConnectionStrings__DefaultConnection=$ConnectionString"
}
$envVars += "ASPNETCORE_ENVIRONMENT=Production"

$appExists = az containerapp show --name $AppName --resource-group $ResourceGroup 2>$null
if (-not $appExists) {
	# Criar nova Container App
	$createCmd = "az containerapp create " +
		"--name $AppName " +
		"--resource-group $ResourceGroup " +
		"--environment $envName " +
		"--image $imageName " +
		"--target-port 8080 " +
		"--ingress external " +
		"--registry-server $acrServer " +
		"--registry-username $acrUser " +
		"--registry-password `"$acrPassword`" " +
		"--cpu 0.5 --memory 1.0Gi " +
		"--min-replicas 1 --max-replicas 3"

	if ($envVars.Count -gt 0) {
		$envVarsStr = ($envVars | ForEach-Object { "`"$_`"" }) -join " "
		$createCmd += " --env-vars $envVarsStr"
	}

	Invoke-Expression "$createCmd --output none"
	Write-Success "Container App criado"
} else {
	# Atualizar Container App existente
	$updateCmd = "az containerapp update " +
		"--name $AppName " +
		"--resource-group $ResourceGroup " +
		"--image $imageName"

	if ($envVars.Count -gt 0) {
		$envVarsStr = ($envVars | ForEach-Object { "`"$_`"" }) -join " "
		$updateCmd += " --set-env-vars $envVarsStr"
	}

	Invoke-Expression "$updateCmd --output none"
	Write-Success "Container App atualizado"
}

# 8. Obter URL da aplicação
Write-Step "Obtendo URL da aplicação..."
$app = az containerapp show --name $AppName --resource-group $ResourceGroup | ConvertFrom-Json
$appUrl = "https://$($app.properties.configuration.ingress.fqdn)"

# 9. Resumo Final
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              DEPLOY CONCLUÍDO COM SUCESSO!               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📍 URL da Aplicação:"
Write-Host "   $appUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 Swagger Documentation:"
Write-Host "   $appUrl/swagger" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 Health Check:"
Write-Host "   $appUrl/health" -ForegroundColor Cyan
Write-Host ""

if (-not $SkipDatabase) {
	Write-Host "📦 Banco de Dados Azure SQL:"
	Write-Host "   Server: $SqlServer.database.windows.net"
	Write-Host "   Database: $SqlDatabase"
	Write-Host "   User: $SqlAdminUser"
	Write-Host "   Password: $SqlAdminPassword"
	Write-Host "   ⚠️  SALVE ESTAS INFORMAÇÕES EM LOCAL SEGURO!" -ForegroundColor Red
	Write-Host ""
}

Write-Host "🔧 Gerenciar recursos:"
Write-Host "   Portal Azure: https://portal.azure.com"
Write-Host "   Resource Group: $ResourceGroup"
Write-Host ""
Write-Host "💰 Custos Estimados (após período gratuito):"
Write-Host "   Container Apps: ~`$5-10/mês"
Write-Host "   SQL Database Basic: ~`$5/mês"
Write-Host "   Container Registry: ~`$5/mês"
Write-Host "   TOTAL: ~`$15-20/mês"
Write-Host ""
Write-Host "✅ Próximos Passos:"
Write-Host "   1. Testar a aplicação em: $appUrl/swagger"
Write-Host "   2. Configurar domínio personalizado (opcional)"
Write-Host "   3. Configurar CI/CD com GitHub Actions (opcional)"
Write-Host "   4. Adicionar chaves OpenAI e Stripe nas variáveis de ambiente"
Write-Host ""

# Salvar informações em arquivo
$deployInfo = @{
	DeployDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
	AppUrl = $appUrl
	ResourceGroup = $ResourceGroup
	ContainerApp = $AppName
	SqlServer = if (-not $SkipDatabase) { "$SqlServer.database.windows.net" } else { "N/A" }
	SqlDatabase = if (-not $SkipDatabase) { $SqlDatabase } else { "N/A" }
	SqlUser = if (-not $SkipDatabase) { $SqlAdminUser } else { "N/A" }
	SqlPassword = if (-not $SkipDatabase) { $SqlAdminPassword } else { "N/A" }
	ConnectionString = if ($ConnectionString) { $ConnectionString } else { "N/A" }
}

$deployInfo | ConvertTo-Json | Out-File -FilePath "azure-deploy-info.json" -Encoding UTF8
Write-Success "Informações salvas em: azure-deploy-info.json"

Write-Host ""
Write-Host "🎉 Deploy finalizado! Boa sorte com sua plataforma!" -ForegroundColor Magenta
