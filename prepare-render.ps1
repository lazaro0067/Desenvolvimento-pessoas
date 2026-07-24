# 🚀 Script de Preparação para Deploy no Render.com
# Plataforma Desenvolvimento de Pessoas

param(
	[switch]$SkipBuild,
	[switch]$InitGit
)

# Cores
function Write-Step { param($msg) Write-Host "► $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Error { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "ℹ $msg" -ForegroundColor Yellow }

# Banner
Write-Host @"
╔══════════════════════════════════════════════════════════╗
║   RENDER.COM DEPLOYMENT - Desenvolvimento de Pessoas     ║
║   Preparação para deploy gratuito                        ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

# Validar ferramentas
Write-Step "Validando ferramentas necessárias..."

# .NET SDK
try {
	$dotnetVersion = dotnet --version
	Write-Success ".NET SDK instalado: $dotnetVersion"
} catch {
	Write-Error ".NET SDK não encontrado!"
	Write-Info "Instale de: https://dotnet.microsoft.com/download"
	exit 1
}

# Git
try {
	$gitVersion = git --version
	Write-Success "Git instalado: $gitVersion"
} catch {
	Write-Error "Git não encontrado!"
	Write-Info "Instale de: https://git-scm.com/downloads"
	exit 1
}

# Verificar se render.yaml existe
if (-not (Test-Path "render.yaml")) {
	Write-Error "render.yaml não encontrado no diretório atual!"
	exit 1
}
Write-Success "render.yaml encontrado"

# Build do projeto (se não skipped)
if (-not $SkipBuild) {
	Write-Step "Fazendo build do projeto..."
	$buildResult = dotnet build src/Api/Desenvolvimento.Api.csproj -c Release 2>&1
	if ($LASTEXITCODE -ne 0) {
		Write-Error "Falha no build do projeto"
		Write-Host $buildResult
		exit 1
	}
	Write-Success "Build concluído com sucesso"
} else {
	Write-Info "Build ignorado (--SkipBuild)"
}

# Inicializar Git (se solicitado)
if ($InitGit) {
	Write-Step "Inicializando repositório Git..."

	if (Test-Path ".git") {
		Write-Info "Repositório Git já existe"
	} else {
		git init
		Write-Success "Repositório Git inicializado"

		# Criar .gitignore se não existir
		if (-not (Test-Path ".gitignore")) {
			Write-Step "Criando .gitignore..."
			@"
# Build results
[Bb]in/
[Oo]bj/
[Pp]ublish/

# User-specific files
*.user
*.suo
*.userosscache
*.sln.docstates

# Visual Studio
.vs/
.vscode/

# Rider
.idea/

# Azure
azure-deploy-info.json

# Environment files
.env
.env.local
*.env

# Logs
*.log

# Database
*.db
*.db-shm
*.db-wal

# OS files
.DS_Store
Thumbs.db
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8
			Write-Success ".gitignore criado"
		}
	}
}

# Verificar GitHub CLI (opcional)
$hasGhCli = $null -ne (Get-Command "gh" -ErrorAction SilentlyContinue)
if ($hasGhCli) {
	Write-Success "GitHub CLI detectado (gh)"
} else {
	Write-Info "GitHub CLI não detectado (opcional)"
	Write-Info "Para criar repo automaticamente, instale: winget install GitHub.cli"
}

# Resumo e próximos passos
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║           PREPARAÇÃO CONCLUÍDA COM SUCESSO!              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "📋 PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1️⃣  CRIAR REPOSITÓRIO NO GITHUB" -ForegroundColor Cyan
Write-Host "   Opção A - Via GitHub Web:"
Write-Host "   • Acesse: https://github.com/new"
Write-Host "   • Nome: desenvolvimento-pessoas"
Write-Host "   • Visibilidade: Private (recomendado) ou Public"
Write-Host "   • NÃO inicialize com README, .gitignore ou license"
Write-Host ""
Write-Host "   Opção B - Via GitHub CLI (se instalado):"
Write-Host "   gh repo create desenvolvimento-pessoas --private --source=. --push"
Write-Host ""

Write-Host "2️⃣  FAZER COMMIT E PUSH INICIAL" -ForegroundColor Cyan
Write-Host "   git add ."
Write-Host "   git commit -m 'Initial commit - Plataforma Desenvolvimento de Pessoas'"
Write-Host "   git branch -M main"
Write-Host "   git remote add origin https://github.com/SEU-USUARIO/desenvolvimento-pessoas.git"
Write-Host "   git push -u origin main"
Write-Host ""

Write-Host "3️⃣  CRIAR CONTA NO RENDER.COM" -ForegroundColor Cyan
Write-Host "   • Acesse: https://render.com"
Write-Host "   • Clique em 'Get Started for Free'"
Write-Host "   • Faça login com GitHub (recomendado) ou email"
Write-Host "   • Autorize Render a acessar seus repositórios"
Write-Host ""

Write-Host "4️⃣  FAZER DEPLOY NO RENDER" -ForegroundColor Cyan
Write-Host "   No dashboard do Render:"
Write-Host "   • Clique em 'New +' → 'Blueprint'"
Write-Host "   • Selecione o repositório 'desenvolvimento-pessoas'"
Write-Host "   • Clique em 'Connect'"
Write-Host "   • Render lerá o arquivo render.yaml automaticamente"
Write-Host "   • Clique em 'Apply' para criar os recursos"
Write-Host ""
Write-Host "   Aguarde 5-10 minutos para o primeiro deploy completar."
Write-Host ""

Write-Host "5️⃣  ACESSAR SUA APLICAÇÃO" -ForegroundColor Cyan
Write-Host "   Após deploy:"
Write-Host "   • URL será mostrada no dashboard: https://desenvolvimento-pessoas-api.onrender.com"
Write-Host "   • Health check: https://desenvolvimento-pessoas-api.onrender.com/health"
Write-Host "   • Swagger: https://desenvolvimento-pessoas-api.onrender.com/swagger"
Write-Host ""

Write-Host "⚠️  IMPORTANTE - LIMITAÇÕES DO FREE TIER:" -ForegroundColor Yellow
Write-Host "   • Aplicação 'dorme' após 15 minutos de inatividade"
Write-Host "   • Primeira requisição após sleep leva ~30 segundos (cold start)"
Write-Host "   • 750 horas/mês de runtime (suficiente para desenvolvimento)"
Write-Host "   • 512 MB de RAM"
Write-Host "   • PostgreSQL: 500 MB storage, backup de 90 dias"
Write-Host ""

Write-Host "📚 DOCUMENTAÇÃO COMPLETA:" -ForegroundColor Cyan
Write-Host "   Guia detalhado: RENDER_DEPLOY.md (será criado no próximo passo)"
Write-Host ""

Write-Host "🎉 Sucesso! Execute os passos acima para publicar gratuitamente!" -ForegroundColor Magenta

# Salvar informações em arquivo
$prepareInfo = @{
	PrepareDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
	DotNetVersion = $dotnetVersion
	GitVersion = $gitVersion
	RenderYamlExists = Test-Path "render.yaml"
	BuildCompleted = -not $SkipBuild
	GitInitialized = $InitGit
}

$prepareInfo | ConvertTo-Json | Out-File -FilePath "render-prepare-info.json" -Encoding UTF8
Write-Success "Informações salvas em: render-prepare-info.json"
