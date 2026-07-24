# Script de Publicação Automatizada - Desenvolvimento de Pessoas
# PowerShell Script

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Publicação: Desenvolvimento de Pessoas - API" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Limpar publicação anterior
Write-Host "[1/5] Limpando publicação anterior..." -ForegroundColor Yellow
if (Test-Path ".\publish\api") {
	Remove-Item ".\publish\api" -Recurse -Force
	Write-Host "✓ Pasta publish limpa" -ForegroundColor Green
}

# 2. Compilar em Release
Write-Host "[2/5] Compilando projeto em Release..." -ForegroundColor Yellow
dotnet build src\Api\Desenvolvimento.Api.csproj --configuration Release --no-incremental
if ($LASTEXITCODE -ne 0) {
	Write-Host "✗ Erro na compilação!" -ForegroundColor Red
	exit 1
}
Write-Host "✓ Compilação concluída" -ForegroundColor Green

# 3. Publicar
Write-Host "[3/5] Publicando aplicação..." -ForegroundColor Yellow
dotnet publish src\Api\Desenvolvimento.Api.csproj --configuration Release --output .\publish\api --no-build
if ($LASTEXITCODE -ne 0) {
	Write-Host "✗ Erro na publicação!" -ForegroundColor Red
	exit 1
}
Write-Host "✓ Publicação concluída" -ForegroundColor Green

# 4. Copiar arquivos de configuração
Write-Host "[4/5] Copiando arquivos de configuração..." -ForegroundColor Yellow
Copy-Item "Dockerfile" ".\publish\" -Force -ErrorAction SilentlyContinue
Copy-Item "docker-compose.yml" ".\publish\" -Force -ErrorAction SilentlyContinue
Copy-Item "DEPLOY.md" ".\publish\" -Force -ErrorAction SilentlyContinue
Write-Host "✓ Arquivos copiados" -ForegroundColor Green

# 5. Resumo
Write-Host "[5/5] Gerando resumo..." -ForegroundColor Yellow
$files = Get-ChildItem ".\publish\api" -File
$totalSize = ($files | Measure-Object -Property Length -Sum).Sum / 1MB
$fileCount = $files.Count

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " PUBLICAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Localização: .\publish\api" -ForegroundColor White
Write-Host "📦 Total de arquivos: $fileCount" -ForegroundColor White
Write-Host "💾 Tamanho total: $([math]::Round($totalSize, 2)) MB" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Para executar localmente:" -ForegroundColor Yellow
Write-Host "   cd publish\api" -ForegroundColor Gray
Write-Host "   dotnet Desenvolvimento.Api.dll" -ForegroundColor Gray
Write-Host ""
Write-Host "🐳 Para executar com Docker:" -ForegroundColor Yellow
Write-Host "   cd publish" -ForegroundColor Gray
Write-Host "   docker-compose up -d" -ForegroundColor Gray
Write-Host ""
Write-Host "📖 Para mais informações, consulte DEPLOY.md" -ForegroundColor White
Write-Host ""
