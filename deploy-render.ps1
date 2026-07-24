# ============================================
# Script de Deploy Render.com
# Plataforma: Desenvolvimento de Pessoas
# ============================================

param(
	[switch]$CheckOnly,
	[switch]$InitGit,
	[switch]$CommitAndPush,
	[string]$CommitMessage = "Update: deployment ready",
	[switch]$Help
)

$ErrorActionPreference = "Stop"
$workspaceRoot = Get-Location

# Cores
function Write-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }
function Write-Step { param($msg) Write-Host "`n🔹 $msg" -ForegroundColor Blue }

# Help
if ($Help) {
	Write-Host @"
🚀 Deploy Render.com - Script de Automação

USO:
	.\deploy-render.ps1 [opções]

OPÇÕES:
	-CheckOnly          Apenas verifica requisitos (não faz mudanças)
	-InitGit            Inicializa Git no diretório atual
	-CommitAndPush      Faz commit e push para GitHub
	-CommitMessage      Mensagem do commit (padrão: "Update: deployment ready")
	-Help               Mostra esta ajuda

EXEMPLOS:
	# 1. Verificar requisitos
	.\deploy-render.ps1 -CheckOnly

	# 2. Inicializar Git
	.\deploy-render.ps1 -InitGit

	# 3. Commit e push
	.\deploy-render.ps1 -CommitAndPush -CommitMessage "feat: adicionar DISC model"

	# 4. Tudo de uma vez
	.\deploy-render.ps1 -InitGit
	.\deploy-render.ps1 -CommitAndPush

WORKFLOW COMPLETO:
	1. Instalar Git: https://git-scm.com/download/win
	2. .\deploy-render.ps1 -CheckOnly
	3. .\deploy-render.ps1 -InitGit
	4. Criar repo no GitHub: https://github.com/new
	5. git remote add origin https://github.com/SEU_USUARIO/seu-repo.git
	6. .\deploy-render.ps1 -CommitAndPush
	7. Deploy no Render: https://render.com → New Blueprint

"@
	exit 0
}

Write-Host "`n" -NoNewline
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║         🚀 DEPLOY RENDER.COM - AUTOMAÇÃO               ║" -ForegroundColor Magenta
Write-Host "║    Plataforma: Desenvolvimento de Pessoas               ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# ============================================
# 1. VERIFICAR REQUISITOS
# ============================================
Write-Step "Verificando Requisitos"

## 1.1 Git
try {
	$gitVersion = git --version 2>$null
	if ($gitVersion) {
		Write-Success "Git instalado: $gitVersion"
		$gitInstalled = $true
	}
} catch {
	Write-Warning "Git NÃO está instalado"
	Write-Info "   Baixe em: https://git-scm.com/download/win"
	$gitInstalled = $false
}

## 1.2 .NET SDK
try {
	$dotnetVersion = dotnet --version 2>$null
	if ($dotnetVersion) {
		Write-Success ".NET SDK instalado: $dotnetVersion"
		$dotnetInstalled = $true
	}
} catch {
	Write-Error ".NET SDK NÃO está instalado"
	$dotnetInstalled = $false
}

## 1.3 Arquivos críticos
$criticalFiles = @(
	"render.yaml",
	"Dockerfile",
	"src/Api/Desenvolvimento.Api.csproj"
)

$allFilesExist = $true
foreach ($file in $criticalFiles) {
	if (Test-Path $file) {
		Write-Success "Arquivo encontrado: $file"
	} else {
		Write-Error "Arquivo FALTANDO: $file"
		$allFilesExist = $false
	}
}

## 1.4 Summary
Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
if ($gitInstalled -and $dotnetInstalled -and $allFilesExist) {
	Write-Success "TODOS OS REQUISITOS ATENDIDOS!"
	$canProceed = $true
} else {
	Write-Warning "ALGUNS REQUISITOS NÃO FORAM ATENDIDOS"
	$canProceed = $false
}
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan

if ($CheckOnly) {
	Write-Info "Modo CheckOnly: finalizando"
	exit 0
}

if (-not $canProceed) {
	Write-Error "Corrija os problemas acima antes de continuar"
	exit 1
}

# ============================================
# 2. INICIALIZAR GIT (se solicitado)
# ============================================
if ($InitGit) {
	Write-Step "Inicializando Git"

	if (Test-Path ".git") {
		Write-Warning "Repositório Git já existe"
	} else {
		git init
		Write-Success "Git inicializado"

		# Criar .gitignore
		if (-not (Test-Path ".gitignore")) {
			Write-Info "Criando .gitignore..."

			$gitignoreContent = @"
## Visual Studio / .NET
bin/
obj/
publish/
.vs/
*.user
*.suo
*.cache
.vscode/

## Environment files
.env
.env.local
appsettings.Development.json

## OS files
.DS_Store
Thumbs.db

## Database
*.db
*.db-shm
*.db-wal

## Logs
logs/
*.log

## Docker
.dockerignore
"@
			$gitignoreContent | Out-File -FilePath .gitignore -Encoding UTF8
			Write-Success ".gitignore criado"
		} else {
			Write-Info ".gitignore já existe"
		}

		# Primeiro commit
		Write-Info "Adicionando arquivos..."
		git add .

		Write-Info "Criando commit inicial..."
		git commit -m "chore: initial commit - plataforma desenvolvimento de pessoas"

		Write-Success "Repositório Git inicializado com sucesso!"
		Write-Info ""
		Write-Info "PRÓXIMOS PASSOS:"
		Write-Info "1. Crie um repositório no GitHub: https://github.com/new"
		Write-Info "2. Conecte o remote:"
		Write-Host "   git remote add origin https://github.com/SEU_USUARIO/seu-repo.git" -ForegroundColor Yellow
		Write-Host "   git branch -M main" -ForegroundColor Yellow
		Write-Host "   git push -u origin main" -ForegroundColor Yellow
		Write-Info ""
	}
}

# ============================================
# 3. COMMIT E PUSH (se solicitado)
# ============================================
if ($CommitAndPush) {
	Write-Step "Commit e Push"

	if (-not (Test-Path ".git")) {
		Write-Error "Git não inicializado! Execute: .\deploy-render.ps1 -InitGit"
		exit 1
	}

	# Verificar se há remote configurado
	$remotes = git remote 2>$null
	if (-not $remotes) {
		Write-Error "Nenhum remote configurado!"
		Write-Info "Configure com:"
		Write-Host "   git remote add origin https://github.com/SEU_USUARIO/seu-repo.git" -ForegroundColor Yellow
		exit 1
	}

	# Status
	$status = git status --porcelain
	if (-not $status) {
		Write-Info "Nenhuma mudança para commit"
	} else {
		Write-Info "Mudanças detectadas:"
		git status --short

		Write-Info ""
		Write-Info "Adicionando arquivos..."
		git add .

		Write-Info "Criando commit..."
		git commit -m $CommitMessage

		Write-Success "Commit criado: $CommitMessage"
	}

	# Push
	Write-Info "Enviando para GitHub..."
	try {
		git push
		Write-Success "Push realizado com sucesso!"
		Write-Info ""
		Write-Success "✨ DEPLOY AUTOMÁTICO INICIADO NO RENDER! ✨"
		Write-Info ""
		Write-Info "Acompanhe em: https://dashboard.render.com"
	} catch {
		Write-Warning "Push falhou. Tente:"
		Write-Host "   git push -u origin main" -ForegroundColor Yellow
	}
}

# ============================================
# 4. INFORMAÇÕES FINAIS
# ============================================
if (-not $InitGit -and -not $CommitAndPush) {
	Write-Info ""
	Write-Info "Nenhuma ação executada. Use:"
	Write-Host "   .\deploy-render.ps1 -Help" -ForegroundColor Yellow
	Write-Info "para ver as opções disponíveis"
}

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Green
Write-Success "Script concluído!"
Write-Host "═══════════════════════════════════════" -ForegroundColor Green
Write-Host ""

# Salvar informações do deploy
$deployInfo = @{
	timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	workspace = $workspaceRoot.Path
	gitInstalled = $gitInstalled
	dotnetVersion = $dotnetVersion
	renderUrl = "https://dashboard.render.com"
	githubNewRepo = "https://github.com/new"
	documentation = @(
		"DEPLOY_RENDER_PASSO_A_PASSO.md",
		"RENDER_DEPLOY.md",
		"RENDER_LIMITS.md",
		"POSTGRESQL_GUIDE.md",
		"ACESSO_RENDER.md"
	)
}

$deployInfo | ConvertTo-Json -Depth 3 | Out-File "deploy-info.json" -Encoding UTF8
Write-Info "Informações salvas em: deploy-info.json"
