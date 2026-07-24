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

---

## ☁️ AMBIENTE PRODUÇÃO (Render.com - GRATUITO)

### 🚀 Como Publicar

Siga o guia rápido: **[RENDER_DEPLOY.md](RENDER_DEPLOY.md)**

**Comando único:**
```powershell
.\prepare-render.ps1 -InitGit
```

Depois:
1. Criar repositório no GitHub
2. Fazer push do código
3. Criar conta no Render.com (gratuito, sem cartão)
4. Conectar repositório → Deploy automático!

### 📍 URLs Públicas (Após Deploy)

| Recurso | URL | Descrição |
|---------|-----|-----------|
| **Health Check** | `https://desenvolvimento-pessoas-api.onrender.com/health` | Verifica se API está online |
| **Swagger UI** | `https://desenvolvimento-pessoas-api.onrender.com/swagger` | Documentação interativa |
| **OpenAPI JSON** | `https://desenvolvimento-pessoas-api.onrender.com/swagger/v1/swagger.json` | Especificação OpenAPI |
| **Endpoint Base** | `https://desenvolvimento-pessoas-api.onrender.com/api` | Base URL para endpoints |

**⚠️ Nota sobre URL:**
- A URL exata será gerada após o deploy
- Formato: `https://[seu-service-name].onrender.com`
- Você pode customizar o nome do serviço durante a configuração

### ⏳ Importante - Sleep Policy

**Render.com Free Tier:**
- Aplicação "dorme" após **15 minutos** de inatividade
- Primeira requisição após sleep leva **~30-60 segundos** (cold start)
- Requisições subsequentes são instantâneas

**Como evitar sleep:**
- Configure keep-alive automático (veja [RENDER_LIMITS.md](RENDER_LIMITS.md))
- Use UptimeRobot ou GitHub Actions para pingar a cada 10 minutos

### 🔑 Credenciais Render.com

**Banco de Dados PostgreSQL:**
- Gerado automaticamente pelo Render
- Acesse: Dashboard → Database → Info → Show
- Connection string injetada automaticamente na aplicação

**⚠️ IMPORTANTE:** 
- Credenciais são gerenciadas pelo Render
- Nunca commitar connection strings no Git
- Variáveis de ambiente são configuradas automaticamente

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

### Exemplos de Requisição

#### PowerShell (Local)
```powershell
$baseUrl = "http://localhost:5000"

# Health Check
Invoke-RestMethod -Uri "$baseUrl/health"

# Criar usuário Master
$body = @{
	email = "admin@exemplo.com"
	password = "Admin@123456"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$baseUrl/api/admin/ensure" -Method POST -Body $body -ContentType "application/json"
```

#### PowerShell (Render.com Produção)
```powershell
$baseUrl = "https://desenvolvimento-pessoas-api.onrender.com"

# Health Check (primeira requisição pode demorar 30-60s se estava dormindo)
Invoke-RestMethod -Uri "$baseUrl/health"

# Criar usuário Master
$body = @{
	email = "admin@exemplo.com"
	password = "Admin@123456"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$baseUrl/api/admin/ensure" -Method POST -Body $body -ContentType "application/json"
```

#### cURL (Linux/Mac)
```bash
# Health Check
curl https://desenvolvimento-pessoas-api.onrender.com/health

# Criar usuário Master
curl -X POST https://desenvolvimento-pessoas-api.onrender.com/api/admin/ensure \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@exemplo.com","password":"Admin@123456"}'
```

---

## 🔧 GERENCIAMENTO

### Render.com Dashboard

- **URL:** https://dashboard.render.com
- **Serviço:** `desenvolvimento-pessoas-api`
- **Database:** `desenvolvimento-pessoas-db`

**Ações comuns:**
- Ver logs em tempo real
- Monitorar métricas (CPU, RAM, requests)
- Fazer redeploy manual
- Configurar variáveis de ambiente
- Ver histórico de deploys

### Atualizar Aplicação (Redeploy)

```powershell
# 1. Fazer alterações no código
# ...

# 2. Commit e push
git add .
git commit -m "feat: adicionar novo endpoint"
git push origin main

# 3. Render detecta push e faz deploy automático (~5-10 min)
```

### Adicionar Variáveis de Ambiente

**Via Dashboard:**
1. Dashboard → `desenvolvimento-pessoas-api`
2. Aba **"Environment"**
3. Adicionar variável:
   ```
   OpenAI__ApiKey = sk-proj-...
   ```
4. **Save Changes** → Redeploy automático

**Variáveis úteis:**
```
OpenAI__ApiKey=sk-proj-...
OpenAI__Model=gpt-4
Stripe__SecretKey=sk_test_...
Stripe__PublishableKey=pk_test_...
```

---

## 📊 MONITORAMENTO

### Logs em Tempo Real

**Via Dashboard:**
- Serviço → aba **"Logs"**
- Filtrar por erro, warning ou info

**Via Render CLI (opcional):**
```powershell
# Instalar
npm install -g @render/cli

# Login
render login

# Ver logs
render logs desenvolvimento-pessoas-api
```

### Métricas

Dashboard → Serviço → aba **"Metrics"**:
- **CPU Usage** - Uso de CPU (%)
- **Memory Usage** - Uso de memória (MB / 512 MB)
- **HTTP Requests** - Requisições por minuto
- **Response Time** - Latência média

### Alertas

Configure alertas via:
- **UptimeRobot:** https://uptimerobot.com (gratuito)
- **Monitorar:** `https://desenvolvimento-pessoas-api.onrender.com/health`
- **Alerta:** Se ficar down > 5 minutos

---

## 🆘 TROUBLESHOOTING

### ❌ "Application está dormindo (sleep)"

**Sintoma:**
- Primeira requisição demora 30-60s
- Requisições subsequentes são rápidas

**Solução:**
- É comportamento normal do free tier
- Configure keep-alive (veja [RENDER_LIMITS.md](RENDER_LIMITS.md))

### ❌ "502 Bad Gateway"

**Sintoma:**
- Ao acessar URL, retorna erro 502

**Soluções:**
1. Aguardar 60 segundos (cold start)
2. Ver logs no dashboard para identificar erro
3. Verificar se build falhou

### ❌ "Database connection failed"

**Sintoma:**
- Logs mostram erro de conexão ao PostgreSQL

**Soluções:**
1. Verificar se database está "Available" no dashboard
2. Verificar connection string em Environment
3. Testar conexão manual (veja [POSTGRESQL_GUIDE.md](POSTGRESQL_GUIDE.md))

### ❌ "Build falhou"

**Sintoma:**
- Deploy trava em "Building"

**Soluções:**
1. Ver logs de build no dashboard
2. Testar build localmente: `docker build -f Dockerfile .`
3. Limpar cache: Settings → "Clear build cache & deploy"

### Mais Soluções

Veja guias completos:
- **Deploy:** [RENDER_DEPLOY.md](RENDER_DEPLOY.md)
- **Limitações:** [RENDER_LIMITS.md](RENDER_LIMITS.md)
- **PostgreSQL:** [POSTGRESQL_GUIDE.md](POSTGRESQL_GUIDE.md)

---

## 💰 CUSTOS

### Render.com Free Tier

| Recurso | Limite Gratuito |
|---------|-----------------|
| **Web Service** | 750 horas/mês |
| **RAM** | 512 MB |
| **PostgreSQL** | 500 MB storage |
| **Bandwidth** | 100 GB/mês |
| **Build Time** | Ilimitado |
| **Deploys** | Ilimitados |
| **SSL/HTTPS** | Incluído |

**Sem custos ocultos:**
- ✅ Não precisa de cartão de crédito
- ✅ Totalmente gratuito permanentemente
- ✅ Sem cobrança após período trial

**Upgrade opcional:**
- **Starter Plan:** $7/mês (sem sleep, mesma RAM)
- **Standard Plan:** $25/mês (2 GB RAM, 1 vCPU)

---

## 📝 COMPARATIVO DE AMBIENTES

| Característica | Local | Render.com Free |
|----------------|-------|-----------------|
| **URL** | localhost:5000 | .onrender.com |
| **Banco** | SQL Server LocalDB | PostgreSQL |
| **Custo** | Grátis | Grátis |
| **SSL/HTTPS** | Não | Sim |
| **Acesso Público** | Não | Sim |
| **Sleep** | Não | Sim (15 min) |
| **Cold Start** | Instantâneo | 30-60s |

---

## 🎯 PRÓXIMOS PASSOS

### Para Começar

1. ✅ **Testar localmente** - `http://localhost:5000/swagger`
2. ✅ **Publicar gratuitamente** - Seguir [RENDER_DEPLOY.md](RENDER_DEPLOY.md)
3. ✅ **Validar deploy** - Acessar `https://seu-app.onrender.com/swagger`
4. ✅ **Criar usuário master** - Via `/api/admin/ensure`

### Configurações Opcionais

5. ⚙️ **Adicionar API keys** - OpenAI, Stripe (via Environment)
6. ⚙️ **Configurar keep-alive** - Evitar sleep (veja [RENDER_LIMITS.md](RENDER_LIMITS.md))
7. ⚙️ **Custom domain** - Usar domínio próprio
8. ⚙️ **Monitoramento** - UptimeRobot ou alertas

---

## 📚 DOCUMENTAÇÃO COMPLETA

| Arquivo | Descrição |
|---------|-----------|
| **[RENDER_DEPLOY.md](RENDER_DEPLOY.md)** | Guia completo de deploy no Render.com |
| **[RENDER_LIMITS.md](RENDER_LIMITS.md)** | Limitações e otimizações do free tier |
| **[POSTGRESQL_GUIDE.md](POSTGRESQL_GUIDE.md)** | Guia de uso do PostgreSQL gratuito |
| **[QUICKSTART_DEPLOY.md](QUICKSTART_DEPLOY.md)** | Deploy rápido no Azure (alternativa paga) |
| **[PROJETO.md](PROJETO.md)** | Documentação técnica completa |

---

## ✅ CHECKLIST DE VALIDAÇÃO

### Local (Desenvolvimento)
- [ ] `.NET 10 SDK` instalado
- [ ] Aplicação roda localmente
- [ ] `http://localhost:5000/health` retorna OK
- [ ] `http://localhost:5000/swagger` abre documentação
- [ ] Banco de dados SQL Server LocalDB funcional

### Render.com (Produção)
- [ ] Repositório GitHub criado e código enviado
- [ ] Conta Render.com criada (sem cartão)
- [ ] Deploy concluído com sucesso
- [ ] Web service status: **Live** 🟢
- [ ] Database status: **Available** 🟢
- [ ] Health check retorna OK
- [ ] Swagger acessível
- [ ] Usuário master criado

---

**Última atualização:** 2025-06-01  
**Versão:** 3.0 (Incluindo Render.com gratuito)
