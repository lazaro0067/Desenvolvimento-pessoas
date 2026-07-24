# 🚀 Deploy no Render.com - Guia Passo a Passo

## ✅ Status Atual

- ✅ Código pronto e compilado
- ✅ Suporte PostgreSQL configurado
- ✅ Migration `AddAnswersJsonToDiscAnswer` criada
- ✅ `render.yaml` configurado
- ✅ Dockerfile pronto
- ⚠️ Git precisa ser instalado

---

## 📦 Passo 1: Instalar Git

1. **Baixar Git para Windows:**
   - Acesse: https://git-scm.com/download/win
   - Baixe e instale com as opções padrão
   - **Reinicie o Visual Studio** após a instalação

2. **Verificar instalação:**
   ```powershell
   git --version
   ```

---

## 🗂️ Passo 2: Criar Repositório Git Local

No terminal do Visual Studio (PowerShell):

```powershell
cd 'C:\Users\Lázaro\source\repos\Desenvolvimento de pessoas'

# Inicializar Git
git init

# Criar .gitignore (se não existir)
$gitignore = @"
## Visual Studio / .NET
bin/
obj/
publish/
.vs/
*.user
*.suo
*.cache

## Environment files
.env
.env.local
appsettings.Development.json

## OS files
.DS_Store
Thumbs.db

## Docker
.dockerignore
"@

$gitignore | Out-File -FilePath .gitignore -Encoding UTF8

# Adicionar todos os arquivos
git add .

# Fazer o primeiro commit
git commit -m "Initial commit - Plataforma Desenvolvimento de Pessoas"
```

---

## 🌐 Passo 3: Criar Repositório no GitHub

### Opção A: Via GitHub Desktop (Mais Fácil)

1. **Baixar GitHub Desktop:**
   - https://desktop.github.com/

2. **Publicar o repositório:**
   - Abra GitHub Desktop
   - File → Add Local Repository
   - Selecione: `C:\Users\Lázaro\source\repos\Desenvolvimento de pessoas`
   - Clique em "Publish repository"
   - Marque como **Privado** (recomendado)

### Opção B: Via Linha de Comando

1. **Criar conta no GitHub (se não tiver):**
   - https://github.com/signup

2. **Criar novo repositório:**
   - Acesse: https://github.com/new
   - Nome: `desenvolvimento-pessoas`
   - Privado: ✅ (recomendado)
   - **NÃO** marque "Initialize with README"
   - Clique em "Create repository"

3. **Conectar repositório local:**
   ```powershell
   cd 'C:\Users\Lázaro\source\repos\Desenvolvimento de pessoas'

   # Substitua SEU_USUARIO pelo seu usuário GitHub
   git remote add origin https://github.com/SEU_USUARIO/desenvolvimento-pessoas.git

   git branch -M main

   git push -u origin main
   ```

---

## ☁️ Passo 4: Criar Conta no Render.com

1. **Acessar:** https://render.com
2. **Sign Up** com sua conta GitHub
3. **Autorizar** Render a acessar seus repositórios

---

## 🎯 Passo 5: Deploy via Blueprint

1. **No Render Dashboard:**
   - Clique em **"New +"** → **"Blueprint"**

2. **Conectar Repositório:**
   - Selecione o repositório `desenvolvimento-pessoas`
   - Branch: `main`

3. **Render detectará o `render.yaml` automaticamente:**
   ```
   ✅ 1 Web Service
   ✅ 1 PostgreSQL Database
   ```

4. **Configurar:**
   - Service name: `desenvolvimento-pessoas-api`
   - Database name: `desenvolvimento_pessoas_db`
   - Clique em **"Apply"**

5. **Aguardar deploy:**
   - ⏱️ Primeira build: ~5-10 minutos
   - 🔄 Render irá:
	 - Construir a imagem Docker
	 - Criar banco PostgreSQL
	 - Aplicar migrations automaticamente
	 - Iniciar a API

---

## 🔗 Passo 6: Acessar o Sistema

Após o deploy concluir:

### URLs Render.com

```
API Base:    https://desenvolvimento-pessoas-api.onrender.com
Health:      https://desenvolvimento-pessoas-api.onrender.com/health
Swagger:     https://desenvolvimento-pessoas-api.onrender.com/swagger
```

### 🧪 Teste Rápido

**PowerShell:**
```powershell
# Health Check
Invoke-RestMethod -Uri "https://desenvolvimento-pessoas-api.onrender.com/health"

# Swagger UI (abrir no navegador)
Start-Process "https://desenvolvimento-pessoas-api.onrender.com/swagger"
```

**cURL:**
```bash
curl https://desenvolvimento-pessoas-api.onrender.com/health
```

---

## 📊 Passo 7: Monitorar

### Render Dashboard

1. **Logs em Tempo Real:**
   - Dashboard → Seu serviço → "Logs"

2. **Métricas:**
   - CPU e Memória
   - Requests/minuto
   - Status do banco

### Informações do Banco PostgreSQL

No Render Dashboard → Database:

```
Host:     dpg-xxxxx.oregon-postgres.render.com
Port:     5432
Database: desenvolvimento_pessoas_db
Username: desenvolvimento_pessoas_db_user
Password: [gerado automaticamente]
```

**Connection String** (encontre no dashboard):
```
postgresql://user:password@host/database
```

---

## 🔄 Atualizações Futuras

Sempre que fizer mudanças no código:

```powershell
cd 'C:\Users\Lázaro\source\repos\Desenvolvimento de pessoas'

# 1. Commit local
git add .
git commit -m "Descrição das mudanças"

# 2. Push para GitHub
git push

# 3. Render faz deploy automático! 🎉
```

---

## ⚠️ Limitações do Free Tier

### Web Service
- ⏳ **Sleep após 15 min** de inatividade
- ⏱️ **Cold start**: ~30s na primeira requisição
- 🧠 **512 MB RAM**
- ⏰ **750h/mês** de uptime

### PostgreSQL Database
- 💾 **1 GB** de armazenamento
- 🔄 **30 dias** de retenção
- ⚡ Conexões limitadas

### 💡 Dica: Keep-Alive Simples

Crie um **GitHub Actions** para pingar a cada 14 minutos:

1. No seu repositório GitHub, crie: `.github/workflows/keep-alive.yml`

```yaml
name: Keep API Alive

on:
  schedule:
	- cron: '*/14 * * * *'  # A cada 14 minutos
  workflow_dispatch:

jobs:
  ping:
	runs-on: ubuntu-latest
	steps:
	  - name: Ping API
		run: |
		  curl -f https://desenvolvimento-pessoas-api.onrender.com/health || exit 0
```

2. No GitHub: Settings → Actions → General → ✅ Allow all actions

---

## 🆘 Troubleshooting

### ❌ Build Failed

**Verificar logs no Render:**
- Dashboard → Logs → filtro "build"

**Solução comum:**
```powershell
# Garantir que a API compila localmente
dotnet build src/Api/Desenvolvimento.Api.csproj --configuration Release
```

### ❌ 502 Bad Gateway

**Causas:**
- App não iniciou corretamente
- Health check falhando
- Timeout de startup (excedeu 5 min)

**Verificar:**
1. Logs no Render → procure por erros
2. Variável `PORT` está sendo usada
3. Health endpoint `/health` está funcionando

### ❌ Database Connection Failed

**Verificar:**
1. Connection string está correta
2. Render injetou `DATABASE_URL` automaticamente
3. Migration aplicou corretamente

**Logs importantes:**
```
"Database migration started..."
"Database migration completed!"
```

### ❌ Cold Start Muito Lento

**Normal no free tier!** Primeira requisição após sleep:
- ⏱️ ~20-40 segundos

**Melhorar:**
- Use keep-alive (GitHub Actions acima)
- Considere **upgrade** para paid tier ($7/mês = sempre ativo)

---

## 💰 Custos

### Totalmente Grátis
- ✅ API basic
- ✅ PostgreSQL 1GB
- ✅ SSL automático
- ✅ Deploy automático

### Upgrade Sugerido (Futuro)
- **Starter Plan**: $7/mês
  - Sem sleep
  - 1 GB RAM
  - Melhor performance

---

## 📚 Documentação Completa

Mais detalhes em:
- 📘 `RENDER_DEPLOY.md` - Guia completo
- 📘 `RENDER_LIMITS.md` - Limitações e otimizações
- 📘 `POSTGRESQL_GUIDE.md` - Guia do banco
- 📘 `ACESSO_RENDER.md` - URLs e endpoints

---

## ✅ Checklist de Deploy

- [ ] Git instalado
- [ ] Repositório Git local criado
- [ ] .gitignore configurado
- [ ] Repositório GitHub criado
- [ ] Código enviado para GitHub
- [ ] Conta Render criada
- [ ] Blueprint aplicado no Render
- [ ] Deploy concluído com sucesso
- [ ] Health check testado
- [ ] Swagger acessível
- [ ] Banco PostgreSQL conectado
- [ ] (Opcional) Keep-alive configurado

---

## 🎉 Próximos Passos

Após o deploy bem-sucedido:

1. **Testar endpoints principais:**
   - `/api/disc/submit`
   - `/api/profiles`
   - `/api/chat`

2. **Configurar domínio customizado** (opcional):
   - Render → Settings → Custom Domain
   - Exemplo: `api.seusite.com.br`

3. **Monitorar uso:**
   - Dashboard → Metrics
   - Alertas de limite

4. **Backup do banco:**
   - Ver `POSTGRESQL_GUIDE.md`
   - `pg_dump` regular

---

**🚀 Pronto para Deploy!**

Siga os passos acima e em ~30 minutos sua API estará online e acessível globalmente! 🌍
