# Guia de Publicação - Desenvolvimento de Pessoas

## ✅ Publicação Concluída

A API foi publicada com sucesso em: `publish\api\`

## 🚀 Como Executar Localmente

```powershell
cd publish\api
dotnet Desenvolvimento.Api.dll
```

Acesse:
- API: http://localhost:5000
- Swagger: http://localhost:5000/swagger

## 📦 Conteúdo da Publicação

- `Desenvolvimento.Api.dll` - API principal
- `Desenvolvimento.Core.dll` - Modelos
- `Desenvolvimento.Infrastructure.dll` - EF Core + Identity
- `Desenvolvimento.Services.dll` - Serviços (IA, Pagamentos, DISC)
- `appsettings.json` - Configurações
- Todas as dependências necessárias

## 🌐 Deploy em Produção

### Opção 1: Azure App Service

```powershell
# Instalar Azure CLI
az login
az webapp up --name desenvolvimento-pessoas-api --resource-group meu-rg --location brazilsouth
```

### Opção 2: IIS (Windows Server)

1. Instalar .NET 10 Runtime (Hosting Bundle)
2. Criar site no IIS apontando para `publish\api`
3. Configurar pool de aplicação (.NET 10)
4. Atualizar connection string no `appsettings.json`

### Opção 3: Docker

```powershell
# Build da imagem
docker build -t desenvolvimento-pessoas:latest .

# Executar container
docker-compose up -d
```

### Opção 4: Linux/Ubuntu

```bash
# Instalar .NET 10 Runtime
sudo apt-get update
sudo apt-get install -y dotnet-runtime-10.0

# Copiar arquivos publicados
cp -r publish/api /var/www/desenvolvimento-pessoas

# Criar serviço systemd
sudo nano /etc/systemd/system/desenvolvimento-api.service
```

**Arquivo systemd**:
```ini
[Unit]
Description=Desenvolvimento de Pessoas API
After=network.target

[Service]
WorkingDirectory=/var/www/desenvolvimento-pessoas
ExecStart=/usr/bin/dotnet /var/www/desenvolvimento-pessoas/Desenvolvimento.Api.dll
Restart=always
RestartSec=10
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable desenvolvimento-api
sudo systemctl start desenvolvimento-api
sudo systemctl status desenvolvimento-api
```

## 🔧 Configuração de Produção

### Banco de Dados

Atualizar `publish\api\appsettings.json`:

```json
{
  "ConnectionStrings": {
	"DefaultConnection": "Server=seu-servidor;Database=DesenvPessoasDb;User=usuario;Password=senha-segura;TrustServerCertificate=False;"
  }
}
```

### Migrations

```powershell
# Na máquina com acesso ao banco
cd src\Infrastructure
dotnet ef database update --connection "sua-connection-string"
```

### Inicializar Sistema

```powershell
# Criar roles e usuário master
Invoke-RestMethod -Method Post -Uri https://seu-dominio.com/api/admin/ensure
```

## 📋 Checklist Pré-Deploy

- [ ] Atualizar connection string
- [ ] Executar migrations no banco de produção
- [ ] Configurar HTTPS/SSL
- [ ] Atualizar URLs permitidas (CORS)
- [ ] Configurar API keys (OpenAI, Stripe, etc.)
- [ ] Testar endpoint /health
- [ ] Criar usuário Master
- [ ] Backup do banco antes de deploy

## 🔐 Segurança

1. **HTTPS obrigatório** em produção
2. **Secrets**: usar Azure Key Vault, AWS Secrets Manager ou variáveis de ambiente
3. **CORS**: configurar domínios permitidos
4. **Rate Limiting**: implementar para prevenir abuso
5. **Logging**: configurar Application Insights ou Serilog

## 📊 Monitoramento

### Application Insights (Azure)

```csharp
// Adicionar no Program.cs
builder.Services.AddApplicationInsightsTelemetry();
```

### Health Checks

Endpoint já disponível: `GET /health`

### Logs

```powershell
# Ver logs em tempo real
docker logs -f desenvolvimento-api
```

## 🆘 Troubleshooting

### Erro de conexão ao banco
- Verificar connection string
- Testar conectividade: `Test-NetConnection servidor-sql -Port 1433`
- Verificar firewall

### Erro 500 Internal Server Error
- Verificar logs: `docker logs desenvolvimento-api`
- Checar variáveis de ambiente
- Validar appsettings.json

### Performance
- Habilitar cache
- Configurar pool de conexões do EF Core
- Usar load balancer para múltiplas instâncias

## 📞 Suporte

Para dúvidas ou problemas, consulte a documentação completa em PROJETO.md
