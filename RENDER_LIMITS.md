# ⚠️ Limitações e Otimizações - Render.com Free Tier

## 🎯 Visão Geral
Este documento detalha as limitações do tier gratuito do Render.com e estratégias de otimização para maximizar o uso da plataforma.

---

## 📊 LIMITES DO FREE TIER

### Compute (Web Service)
| Recurso | Limite | Detalhes |
|---------|--------|----------|
| **Service Hours** | 750 horas/mês | ~31 dias rodando 24/7 com 1 serviço |
| **RAM** | 512 MB | Aplicação é killed se exceder |
| **CPU** | 0.1 vCPU | CPU compartilhada |
| **Sleep Policy** | 15 minutos | App dorme após inatividade |
| **Cold Start** | 30-60 segundos | Tempo para "acordar" |
| **Concurrent Requests** | Ilimitado | Mas limitado por RAM/CPU |

### Database (PostgreSQL)
| Recurso | Limite | Detalhes |
|---------|--------|----------|
| **Storage** | 500 MB | Dados + índices |
| **Backup Retention** | 90 dias | Depois disso, é deletado |
| **Connections** | 97 | Conexões simultâneas |
| **Inactive Period** | 90 dias | Database é deletado se não usado |

### Outros
| Recurso | Limite |
|---------|--------|
| **Bandwidth** | 100 GB/mês |
| **SSL Certificates** | Incluído |
| **Build Time** | Ilimitado |
| **Deploy Frequency** | Ilimitado |

---

## 💤 SLEEP POLICY (Principal Limitação)

### Como Funciona

1. **Aplicação fica 15 minutos sem requisições** → Render coloca em sleep
2. **Nova requisição chega** → Aplicação é "acordada"
3. **Cold start** → Leva 30-60 segundos para iniciar
4. **Requisição é processada** → Cliente pode ver timeout se não aguardar

### Impacto no Usuário

**Primeira requisição após sleep:**
```
Usuário acessa → https://seu-app.onrender.com/swagger
  ↓
Aguarda 30-60 segundos (cold start)
  ↓
Página carrega normalmente
  ↓
Próximas requisições são instantâneas
```

**Experiência real:**
- ✅ **Requisições subsequentes:** < 100ms
- ⏳ **Primeira requisição (cold start):** 30-60s
- ⏸️ **Depois de 15 min sem uso:** Volta a dormir

### Estratégias para Minimizar Sleep

#### 1. Keep-Alive Automático (Recomendado)

**GitHub Actions (dentro do seu repositório):**

Criar arquivo `.github/workflows/keep-alive.yml`:
```yaml
name: Keep Render Alive
on:
  schedule:
	# Rodar a cada 10 minutos (previne sleep)
	- cron: '*/10 * * * *'
  workflow_dispatch:

jobs:
  ping:
	runs-on: ubuntu-latest
	steps:
	  - name: Ping Health Endpoint
		run: |
		  echo "Pinging Render app..."
		  curl -I https://desenvolvimento-pessoas-api.onrender.com/health
		  echo "Ping completed successfully!"
```

Commit e push:
```powershell
git add .github/workflows/keep-alive.yml
git commit -m "feat: add keep-alive workflow"
git push origin main
```

**UptimeRobot (Serviço Externo):**
1. Acesse: https://uptimerobot.com (gratuito)
2. Crie monitor:
   - Type: **HTTP(s)**
   - URL: `https://desenvolvimento-pessoas-api.onrender.com/health`
   - Monitoring Interval: **10 minutes**
3. Salvar

**Cron-job.org:**
1. Acesse: https://cron-job.org
2. Criar novo cron job:
   - URL: `https://desenvolvimento-pessoas-api.onrender.com/health`
   - Interval: `*/10 * * * *` (a cada 10 min)

#### 2. Aceitar Sleep (Para Ambientes de Desenvolvimento)

Se você está OK com cold start:
- **Não faça nada**
- Apenas avise usuários que primeira requisição pode demorar
- Economiza horas do free tier para produção

#### 3. Upgrade para Paid Plan

Se precisar estar sempre ativo:
- **Starter Plan:** $7/mês
  - Sem sleep
  - 512 MB RAM
  - 0.5 vCPU

---

## 🧠 OTIMIZAÇÃO DE MEMÓRIA (512 MB)

### Monitorar Uso de Memória

No dashboard do Render:
- Serviço → aba **"Metrics"**
- Ver gráfico de **Memory Usage**

**Alerta:** Se memória chegar perto de 512 MB consistentemente, aplicação será killed.

### Diagnóstico de Uso Alto

Ver logs para identificar problemas:
```
OutOfMemoryException
System.OutOfMemoryException: Exception of type 'System.OutOfMemoryException' was thrown.
```

OU:

```
Application process exited with code 137 (OOMKilled)
```

### Estratégias de Otimização

#### 1. Limitar Conexões do EF Core

**Program.cs:**
```csharp
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
	options.UseNpgsql(connectionString, npgsqlOptions =>
	{
		// Limitar pool de conexões
		npgsqlOptions.MaxBatchSize(10);
	});

	// Limitar tamanho do cache de queries
	options.UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking);
});
```

**Connection string:**
```
...;Pooling=true;MinPoolSize=0;MaxPoolSize=10;
```

#### 2. Desabilitar Logs Detalhados em Produção

**appsettings.json:**
```json
{
  "Logging": {
	"LogLevel": {
	  "Default": "Warning",  // Não "Information"
	  "Microsoft.EntityFrameworkCore": "Error"  // Não "Warning"
	}
  }
}
```

#### 3. Limitar Tamanho de Response

Se retornar listas grandes, paginar:
```csharp
app.MapGet("/api/courses", async (ApplicationDbContext db, int page = 1, int size = 20) =>
{
	var courses = await db.Courses
		.Skip((page - 1) * size)
		.Take(size)
		.ToListAsync();

	return Results.Ok(new { page, size, data = courses });
});
```

#### 4. Reduzir Dependências

Remover pacagens NuGet não utilizados:
```powershell
dotnet list package
# Identificar pacotes não usados e remover com:
dotnet remove package NomeDoPacote
```

---

## 🗄️ OTIMIZAÇÃO DE DATABASE (500 MB)

### Monitorar Storage

Dashboard → Database → aba **"Info"**:
- **Current Storage:** 123 MB / 500 MB

### Alertar Quando Perto do Limite

Criar endpoint de monitoramento:

**Program.cs:**
```csharp
app.MapGet("/api/admin/db-size", async (ApplicationDbContext db) =>
{
	var query = @"
		SELECT pg_database_size(current_database()) as size_bytes,
			   pg_size_pretty(pg_database_size(current_database())) as size_human
	";

	var result = await db.Database.ExecuteSqlRawAsync(query);
	return Results.Ok(result);
});
```

### Estratégias de Limpeza

#### 1. Deletar Dados Antigos Periodicamente

Criar job de limpeza:
```csharp
app.MapPost("/api/admin/cleanup", async (ApplicationDbContext db) =>
{
	// Deletar mensagens de chat com mais de 90 dias
	var cutoffDate = DateTime.UtcNow.AddDays(-90);
	var oldMessages = db.ChatMessages.Where(m => m.Timestamp < cutoffDate);
	db.ChatMessages.RemoveRange(oldMessages);

	// Deletar logs antigos
	var oldLogs = db.Logs.Where(l => l.CreatedAt < cutoffDate);
	db.Logs.RemoveRange(oldLogs);

	await db.SaveChangesAsync();

	return Results.Ok(new { message = "Cleanup completed" });
});
```

Agendar com Cron-job.org para rodar semanalmente.

#### 2. Limitar Tamanho de Campos

Validar uploads:
```csharp
[MaxLength(5000)]  // Limitar descrições
public string Description { get; set; }

// Validar imagens antes de salvar
if (imageBytes.Length > 1_000_000) // 1 MB
{
	return BadRequest("Image too large");
}
```

#### 3. Usar Blob Storage Externo

Para arquivos grandes (vídeos, PDFs):
- **Cloudflare R2:** 10 GB gratuito
- **Cloudinary:** 25 GB gratuito
- **AWS S3 Free Tier:** 5 GB

Salvar apenas URL no PostgreSQL.

---

## ⚡ OTIMIZAÇÃO DE PERFORMANCE

### 1. Caching em Memória

**Program.cs:**
```csharp
builder.Services.AddMemoryCache();

app.MapGet("/api/courses", async (ApplicationDbContext db, IMemoryCache cache) =>
{
	var cacheKey = "all-courses";

	if (!cache.TryGetValue(cacheKey, out List<Course> courses))
	{
		courses = await db.Courses.ToListAsync();
		cache.Set(cacheKey, courses, TimeSpan.FromMinutes(10));
	}

	return Results.Ok(courses);
});
```

### 2. Índices no Banco de Dados

**ApplicationDbContext.cs:**
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
	base.OnModelCreating(modelBuilder);

	// Índice em campos frequentemente buscados
	modelBuilder.Entity<Course>()
		.HasIndex(c => c.Title);

	modelBuilder.Entity<ChatMessage>()
		.HasIndex(m => m.UserId);
}
```

### 3. Queries Otimizadas

**Evitar N+1:**
```csharp
// ❌ Ruim (N+1)
var users = await db.Users.ToListAsync();
foreach (var user in users)
{
	var permissions = await db.Permissions.Where(p => p.UserId == user.Id).ToListAsync();
}

// ✅ Bom (1 query)
var users = await db.Users
	.Include(u => u.Permissions)
	.ToListAsync();
```

---

## 📊 MONITORAMENTO CONTÍNUO

### Health Check Aprimorado

**Program.cs:**
```csharp
app.MapGet("/health", async (ApplicationDbContext db) =>
{
	try
	{
		// Verificar conexão com database
		await db.Database.CanConnectAsync();

		// Verificar storage
		var dbSize = await db.Database.ExecuteSqlRawAsync(
			"SELECT pg_database_size(current_database())"
		);

		return Results.Ok(new
		{
			status = "ok",
			timestamp = DateTime.UtcNow,
			database = "connected",
			memory = GC.GetTotalMemory(false) / 1_000_000 + " MB"
		});
	}
	catch (Exception ex)
	{
		return Results.Json(new
		{
			status = "error",
			message = ex.Message
		}, statusCode: 503);
	}
});
```

### Logs Estruturados

**appsettings.json:**
```json
{
  "Logging": {
	"LogLevel": {
	  "Default": "Information"
	},
	"Console": {
	  "FormatterName": "json"
	}
  }
}
```

Ver logs no Render: Serviço → aba **"Logs"**

### Alertas Proativos

Configurar UptimeRobot para enviar alertas:
1. Dashboard → Add Alert Contact
2. Email ou SMS
3. Receber alerta se app ficar down > 5 minutos

---

## 🛡️ BACKUP E RECUPERAÇÃO

### Backup Manual do PostgreSQL

**Via Render Dashboard:**
1. Database → aba **"Backups"**
2. Clique em **"Create Manual Backup"**
3. Backup é salvo por 90 dias

**Via pg_dump (local):**
```powershell
# Obter connection string no dashboard
$connStr = "postgresql://user:pass@dpg-xxx.oregon-postgres.render.com/dbname"

# Fazer backup
pg_dump $connStr > backup-$(Get-Date -Format "yyyy-MM-dd").sql

# Ou via Docker (se não tiver pg_dump local)
docker run --rm postgres:16 pg_dump $connStr > backup.sql
```

### Restaurar Backup

**Via psql:**
```powershell
# Conectar
psql $connStr

# Dropar tabelas (cuidado!)
DROP TABLE IF EXISTS "Courses" CASCADE;

# Restaurar
psql $connStr < backup-2025-06-01.sql
```

### Agendar Backup Automático

**GitHub Actions:**
```yaml
name: Weekly Database Backup
on:
  schedule:
	- cron: '0 2 * * 0'  # Todo domingo às 2 AM
  workflow_dispatch:

jobs:
  backup:
	runs-on: ubuntu-latest
	steps:
	  - uses: actions/checkout@v4

	  - name: Backup PostgreSQL
		env:
		  DATABASE_URL: ${{ secrets.DATABASE_URL }}
		run: |
		  docker run --rm postgres:16 pg_dump $DATABASE_URL > backup.sql

	  - name: Upload Backup
		uses: actions/upload-artifact@v4
		with:
		  name: db-backup-${{ github.run_number }}
		  path: backup.sql
		  retention-days: 30
```

---

## 📞 QUANDO CONSIDERAR UPGRADE

### Sinais de que Free Tier Não é Suficiente

- ❌ Aplicação ficando OOMKilled frequentemente
- ❌ Database atingindo 450+ MB (90% do limite)
- ❌ Cold start inaceitável para usuários finais
- ❌ Banda excedendo 80 GB/mês
- ❌ Necessidade de mais de 750 horas/mês

### Planos Pagos do Render

| Plan | Preço | Specs |
|------|-------|-------|
| **Starter** | $7/mês | 512 MB RAM, sem sleep, 0.5 vCPU |
| **Standard** | $25/mês | 2 GB RAM, 1 vCPU |
| **Pro** | $85/mês | 4 GB RAM, 2 vCPU |

**PostgreSQL pago:**
- **Starter:** $7/mês - 1 GB storage, 1 ano backup
- **Standard:** $20/mês - 10 GB storage, 7 dias backup

### Alternativas Gratuitas

Se Render não atender:
- **Railway:** $5 USD de crédito/mês
- **Fly.io:** Free tier mais generoso (256 MB RAM permanente)
- **Oracle Cloud Always Free:** Mais robusto (1 GB RAM, sempre ativo)

---

## ✅ CHECKLIST DE OTIMIZAÇÃO

### Implantado
- [ ] Keep-alive configurado (evitar sleep)
- [ ] Logs reduzidos para Warning em produção
- [ ] Connection pooling configurado (MaxPoolSize=10)
- [ ] Queries paginadas para listas grandes
- [ ] Índices criados em campos frequentes
- [ ] Health check aprimorado implementado

### Monitoramento
- [ ] UptimeRobot configurado (alertas de downtime)
- [ ] Storage do database monitorado semanalmente
- [ ] Memória observada no dashboard
- [ ] Backup manual feito mensalmente

### Limpeza
- [ ] Job de limpeza de dados antigos implementado
- [ ] Dados > 90 dias deletados periodicamente
- [ ] Arquivos grandes movidos para blob storage externo

---

**Última atualização:** 2025-06-01  
**Versão:** 1.0
