# 🐘 Guia PostgreSQL no Render.com

## 🎯 Visão Geral
Este guia detalha como usar o banco de dados PostgreSQL gratuito do Render.com para a Plataforma de Desenvolvimento de Pessoas.

---

## 📊 ESPECIFICAÇÕES DO FREE TIER

| Recurso | Valor |
|---------|-------|
| **Storage** | 500 MB |
| **Connections** | 97 simultâneas |
| **PostgreSQL Version** | 16 (última estável) |
| **Backup Retention** | 90 dias |
| **Região** | Oregon (us-west) |
| **Expiration** | 90 dias sem uso |

---

## 🔑 OBTER CREDENCIAIS

### Via Dashboard

1. Acesse o dashboard do Render
2. Clique no database **"desenvolvimento-pessoas-db"**
3. Aba **"Info"**
4. Seção **"Connections"** → Clique em **"Show"**

**Informações exibidas:**
```
Internal Database URL:
postgresql://desenvolvimento_db_user:SENHAAQUI@dpg-xxx-xxx.oregon-postgres.render.com/desenvolvimento_db

External Database URL:
postgresql://desenvolvimento_db_user:SENHAAQUI@dpg-xxx-a.oregon-postgres.render.com:5432/desenvolvimento_db

PSQL Command:
PGPASSWORD=SENHAAQUI psql -h dpg-xxx-a.oregon-postgres.render.com -U desenvolvimento_db_user desenvolvimento_db
```

### Componentes da Connection String

```
postgresql://[username]:[password]@[host]:[port]/[database]

Exemplo:
postgresql://dev_user:abc123XYZ@dpg-abc123.oregon-postgres.render.com:5432/dev_db
		   ↑         ↑        ↑                                        ↑     ↑
		 user    password   host                                     port  db_name
```

---

## 🔧 CONECTAR AO BANCO

### 1. Via Application (EF Core)

A connection string é injetada automaticamente pelo `render.yaml`:

**Program.cs:**
```csharp
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<ApplicationDbContext>(options =>
	options.UseNpgsql(connectionString));
```

**Render substitui automaticamente:**
```
ConnectionStrings__DefaultConnection = postgresql://user:pass@host:5432/db
```

### 2. Via psql (Terminal)

**Windows (PowerShell):**
```powershell
# Instalar psql via Chocolatey
choco install postgresql

# Ou via Winget
winget install PostgreSQL.PostgreSQL

# Conectar
$env:PGPASSWORD="SENHA_AQUI"
psql -h dpg-xxx.oregon-postgres.render.com -U desenvolvimento_db_user -d desenvolvimento_db
```

**Linux/Mac:**
```bash
# Instalar psql
sudo apt install postgresql-client  # Ubuntu/Debian
brew install postgresql@16           # macOS

# Conectar
PGPASSWORD="SENHA_AQUI" psql -h dpg-xxx.oregon-postgres.render.com -U desenvolvimento_db_user -d desenvolvimento_db
```

### 3. Via Docker (Sem instalar psql)

```powershell
# Windows PowerShell
$connStr = "postgresql://user:pass@dpg-xxx.oregon-postgres.render.com:5432/db"

docker run -it --rm postgres:16 psql $connStr
```

### 4. Via Ferramentas GUI

#### DBeaver (Gratuito, Multiplataforma)

1. Download: https://dbeaver.io/download/
2. New Connection → PostgreSQL
3. Preencher:
   - **Host:** `dpg-xxx.oregon-postgres.render.com`
   - **Port:** `5432`
   - **Database:** `desenvolvimento_db`
   - **Username:** `desenvolvimento_db_user`
   - **Password:** `SUA_SENHA`
   - **SSL:** Desabilitado (Render não requer)
4. Test Connection → OK → Finish

#### pgAdmin (Gratuito)

1. Download: https://www.pgadmin.org/download/
2. Add New Server
3. General tab:
   - **Name:** Render Desenvolvimento Pessoas
4. Connection tab:
   - **Host:** `dpg-xxx.oregon-postgres.render.com`
   - **Port:** `5432`
   - **Maintenance database:** `desenvolvimento_db`
   - **Username:** `desenvolvimento_db_user`
   - **Password:** `SUA_SENHA`
5. Save

#### Azure Data Studio (Gratuito, da Microsoft)

1. Download: https://docs.microsoft.com/en-us/sql/azure-data-studio/download
2. New Connection → PostgreSQL
3. Preencher credenciais
4. Connect

---

## 🗄️ ESTRUTURA DO BANCO

### Tabelas Criadas pelo EF Core

Após primeiro deploy, o banco terá:

```sql
-- Identity (autenticação)
AspNetUsers
AspNetRoles
AspNetUserRoles
AspNetUserClaims
AspNetUserLogins
AspNetRoleClaims
AspNetUserTokens

-- Domínio da aplicação
AppUsers
AppRoles
Profiles
Curriculums
Assessments
Pdis
DiscAnswers
Courses
Tracks
ChatMessages
Subscriptions
UserPermissions
SocialShares

-- Migrations
__EFMigrationsHistory
```

### Ver Tabelas

```sql
-- Listar todas as tabelas
\dt

-- Ver estrutura de uma tabela
\d "Courses"

-- Contar registros
SELECT COUNT(*) FROM "Courses";
```

---

## 🔍 QUERIES ÚTEIS

### Informações do Banco

```sql
-- Versão do PostgreSQL
SELECT version();

-- Tamanho do banco de dados
SELECT pg_size_pretty(pg_database_size(current_database())) AS size;

-- Tamanho de cada tabela
SELECT
	schemaname || '.' || tablename AS table_full_name,
	pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC;

-- Número de conexões ativas
SELECT count(*) FROM pg_stat_activity;

-- Sessões ativas detalhadas
SELECT pid, usename, application_name, client_addr, state, query
FROM pg_stat_activity
WHERE state = 'active';
```

### Monitoramento de Performance

```sql
-- Queries mais lentas (habilitado se pg_stat_statements instalado)
SELECT 
	mean_exec_time,
	calls,
	query
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Tabelas sem índices (possível problema de performance)
SELECT
	schemaname || '.' || tablename AS table_name,
	indexname,
	indexdef
FROM pg_indexes
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY schemaname, tablename;
```

### Limpeza de Dados

```sql
-- Deletar mensagens de chat antigas (> 90 dias)
DELETE FROM "ChatMessages"
WHERE "Timestamp" < NOW() - INTERVAL '90 days';

-- Ver quantos registros serão deletados (antes de executar)
SELECT COUNT(*)
FROM "ChatMessages"
WHERE "Timestamp" < NOW() - INTERVAL '90 days';

-- Vacuum para liberar espaço
VACUUM FULL "ChatMessages";
```

---

## 📦 BACKUP E RESTAURAÇÃO

### Backup via pg_dump

**Backup completo:**
```powershell
# Definir variáveis
$host = "dpg-xxx.oregon-postgres.render.com"
$user = "desenvolvimento_db_user"
$db = "desenvolvimento_db"
$env:PGPASSWORD = "SENHA_AQUI"

# Backup
pg_dump -h $host -U $user -d $db -F c -b -v -f "backup-$(Get-Date -Format 'yyyy-MM-dd').dump"

# Ou formato SQL (texto)
pg_dump -h $host -U $user -d $db > "backup-$(Get-Date -Format 'yyyy-MM-dd').sql"
```

**Backup apenas de dados (sem schema):**
```powershell
pg_dump -h $host -U $user -d $db --data-only > data-only.sql
```

**Backup de tabela específica:**
```powershell
pg_dump -h $host -U $user -d $db -t "Courses" > courses-backup.sql
```

### Restauração

**Restaurar dump completo:**
```powershell
pg_restore -h $host -U $user -d $db -v backup-2025-06-01.dump
```

**Restaurar SQL:**
```powershell
psql -h $host -U $user -d $db < backup-2025-06-01.sql
```

**Restaurar apenas dados:**
```powershell
psql -h $host -U $user -d $db < data-only.sql
```

### Backup via Render Dashboard

1. Database → aba **"Backups"**
2. Clique em **"Create Manual Backup"**
3. Backup é criado em ~1-5 minutos
4. Aparece na lista de backups
5. Clique em **"..."** → **"Download"** para fazer download

**Restaurar via Dashboard:**
1. Aba **"Backups"**
2. Selecione backup desejado
3. **"..."** → **"Restore"**
4. ⚠️ **ATENÇÃO:** Isto sobrescreve TODOS os dados atuais
5. Confirmar restauração

---

## 🚀 MIGRATIONS

### Criar Nova Migration (Localmente)

```powershell
# Navegar para o projeto Infrastructure
cd src/Infrastructure

# Criar migration
dotnet ef migrations add NomeDaMigration --startup-project ../Api

# Aplicar migration localmente
dotnet ef database update --startup-project ../Api
```

### Aplicar Migration no Render

**Automático (Recomendado):**
- Migrations são aplicadas automaticamente no startup (já configurado no Program.cs)

**Manual (via psql):**
```sql
-- Ver migrations aplicadas
SELECT * FROM "__EFMigrationsHistory";

-- Executar migration SQL manualmente (se necessário)
ALTER TABLE "Courses" ADD COLUMN "NewField" TEXT;
INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250601000000_AddNewField', '9.0.0');
```

### Rollback de Migration

```powershell
# Reverter última migration
dotnet ef database update PreviousMigrationName --startup-project ../Api

# Ou via SQL
ALTER TABLE "Courses" DROP COLUMN "NewField";
DELETE FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250601000000_AddNewField';
```

---

## 🔐 SEGURANÇA

### Usuários e Permissões

Free tier do Render:
- ✅ 1 usuário admin (criado automaticamente)
- ❌ Não permite criar usuários adicionais no free tier

**Ver permissões do usuário:**
```sql
\du desenvolvimento_db_user
```

### SSL/TLS

Render PostgreSQL:
- ✅ SSL suportado por padrão
- ⚠️ Mas não obrigatório no free tier

**Forçar SSL na connection string:**
```
postgresql://user:pass@host:5432/db?sslmode=require
```

### Proteger Credenciais

**Nunca commitar connection string no Git!**

Verificar `.gitignore`:
```
# Environment files
.env
.env.local
appsettings.json
appsettings.*.json
azure-deploy-info.json
render-prepare-info.json
```

**Render gerencia credenciais via variáveis de ambiente automaticamente.**

---

## 📊 MONITORAMENTO

### Alertas de Storage

Criar endpoint de monitoramento:

**Program.cs:**
```csharp
app.MapGet("/api/admin/db-health", async (ApplicationDbContext db) =>
{
	var query = @"
		SELECT 
			pg_size_pretty(pg_database_size(current_database())) as size,
			(pg_database_size(current_database())::float / (500 * 1024 * 1024)) * 100 as usage_percent
	";

	var connection = db.Database.GetDbConnection();
	await connection.OpenAsync();

	using var command = connection.CreateCommand();
	command.CommandText = query;

	using var reader = await command.ExecuteReaderAsync();
	await reader.ReadAsync();

	var size = reader.GetString(0);
	var usagePercent = reader.GetDouble(1);

	return Results.Ok(new
	{
		size,
		usagePercent = Math.Round(usagePercent, 2),
		maxSize = "500 MB",
		status = usagePercent > 90 ? "critical" : usagePercent > 70 ? "warning" : "ok"
	});
});
```

Acessar:
```
GET https://seu-app.onrender.com/api/admin/db-health

Response:
{
  "size": "123 MB",
  "usagePercent": 24.6,
  "maxSize": "500 MB",
  "status": "ok"
}
```

### Logs do PostgreSQL

No Render Dashboard:
- Database → aba **"Logs"**
- Ver conexões, queries lentas, erros

---

## 🗑️ LIMPEZA E OTIMIZAÇÃO

### Vacuum (Liberar Espaço)

```sql
-- Vacuum simples (online, não bloqueia)
VACUUM "ChatMessages";

-- Vacuum full (offline, recupera mais espaço)
VACUUM FULL "ChatMessages";

-- Vacuum em todas as tabelas
VACUUM;

-- Ver quanto espaço pode ser recuperado
SELECT
	schemaname || '.' || tablename AS table_name,
	pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS size,
	n_dead_tup AS dead_tuples
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;
```

### Reindex (Otimizar Índices)

```sql
-- Reindexar tabela específica
REINDEX TABLE "Courses";

-- Reindexar banco inteiro (pode levar tempo)
REINDEX DATABASE desenvolvimento_db;
```

### Análise de Performance

```sql
-- Atualizar estatísticas para otimizador
ANALYZE;

-- Análise detalhada de uma tabela
ANALYZE VERBOSE "Courses";
```

---

## ⚠️ LIMITAÇÕES E WORKAROUNDS

### 1. Storage Limitado (500 MB)

**Problema:**
- Aplicação armazena muitos dados

**Workaround:**
- Mover arquivos grandes (imagens, vídeos) para Cloudinary/Cloudflare R2
- Deletar dados antigos periodicamente
- Paginar resultados ao invés de carregar tudo

### 2. Backup Expira (90 dias)

**Problema:**
- Backups automáticos são deletados após 90 dias

**Workaround:**
- Fazer backup manual mensal com `pg_dump`
- Salvar em Dropbox/Google Drive
- Ou usar GitHub Actions para backup automatizado

### 3. Database Expira (90 dias sem uso)

**Problema:**
- Se não houver conexões por 90 dias, database é deletado

**Workaround:**
- Configurar keep-alive (endpoint `/health` acessa banco)
- Fazer login manual pelo menos 1x por mês

### 4. Conexões Limitadas (97)

**Problema:**
- Muitas conexões simultâneas

**Workaround:**
- Configurar connection pooling adequado (MaxPoolSize=10)
- Fechar conexões rapidamente (usar `using` statements)
- Monitorar conexões ativas

---

## 📚 RECURSOS

### Documentação Oficial
- **Render PostgreSQL Docs:** https://render.com/docs/databases
- **PostgreSQL Manual:** https://www.postgresql.org/docs/16/
- **EF Core PostgreSQL:** https://www.npgsql.org/efcore/

### Ferramentas
- **DBeaver:** https://dbeaver.io
- **pgAdmin:** https://www.pgadmin.org
- **Azure Data Studio:** https://aka.ms/azuredatastudio

### Comunidade
- **Render Community:** https://community.render.com
- **PostgreSQL Brasil:** https://www.postgresql.org.br

---

## ✅ CHECKLIST

### Setup Inicial
- [ ] Database criado no Render
- [ ] Connection string configurada automaticamente
- [ ] Conexão testada via `psql` ou DBeaver
- [ ] Migrations aplicadas automaticamente no startup
- [ ] Dados iniciais criados (usuário master)

### Manutenção Regular
- [ ] Backup manual mensal (pg_dump)
- [ ] Monitoramento de storage semanal
- [ ] Limpeza de dados antigos mensalmente
- [ ] Verificar conexões ativas mensalmente

### Otimização
- [ ] Índices criados em campos frequentes
- [ ] Connection pooling configurado (MaxPoolSize=10)
- [ ] Queries otimizadas (evitar N+1)
- [ ] Vacuum executado trimestralmente

---

**Última atualização:** 2025-06-01  
**Versão:** 1.0
