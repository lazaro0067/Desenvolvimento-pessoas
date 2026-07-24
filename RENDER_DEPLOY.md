# 🆓 Guia Completo de Deploy Gratuito no Render.com

## 🎯 Visão Geral
Este guia detalha como publicar a Plataforma de Desenvolvimento de Pessoas **completamente GRÁTIS** no Render.com, sem precisar de cartão de crédito.

**O que você terá:**
- ✅ API pública acessível pela internet
- ✅ HTTPS/SSL gratuito
- ✅ Banco de dados PostgreSQL gratuito (500 MB)
- ✅ Deploy automático a cada push no Git
- ✅ URL personalizada (exemplo: `desenvolvimento-pessoas-api.onrender.com`)

**Limitações do Free Tier:**
- ⏸️ Aplicação "dorme" após 15 minutos de inatividade
- 🕐 Cold start de ~30 segundos na primeira requisição
- 💾 512 MB de RAM
- ⏳ 750 horas/mês de runtime (suficiente para desenvolvimento)
- 🗄️ PostgreSQL: 500 MB storage, backup expira após 90 dias de inatividade

---

## ⏱️ Tempo Estimado
- **Preparação local:** 5 minutos
- **Criar conta Render:** 3 minutos
- **Primeiro deploy:** 8-12 minutos
- **TOTAL:** ~20 minutos

---

## 📋 PRÉ-REQUISITOS

### ✅ Checklist Obrigatória

- [ ] **.NET 10 SDK** instalado
  ```powershell
  dotnet --version  # Deve retornar versão 10.x
  ```

- [ ] **Git** instalado
  ```powershell
  git --version
  ```

- [ ] **Conta GitHub** (gratuita)
  - Se não tiver: https://github.com/signup

- [ ] **Aplicação testada localmente**
  - `http://localhost:5000/health` retorna `{"status":"ok"}`

---

## 🚀 PASSO 1: PREPARAR PROJETO

### 1.1 Executar Script de Preparação

```powershell
# No diretório raiz do projeto
.\prepare-render.ps1 -InitGit
```

Este script irá:
- ✅ Validar .NET SDK e Git
- ✅ Fazer build do projeto
- ✅ Inicializar repositório Git
- ✅ Criar .gitignore adequado
- ✅ Verificar arquivo render.yaml

### 1.2 Fazer Primeiro Commit

```powershell
# Adicionar todos os arquivos
git add .

# Criar commit inicial
git commit -m "Initial commit - Plataforma Desenvolvimento de Pessoas"

# Renomear branch para 'main'
git branch -M main
```

---

## 🐙 PASSO 2: CRIAR REPOSITÓRIO NO GITHUB

### Opção A: Via GitHub Web (Mais

 Simples)

1. Acesse: https://github.com/new
2. Preencha:
   - **Repository name:** `desenvolvimento-pessoas`
   - **Visibility:** `Private` (recomendado) ou `Public`
   - ⚠️ **NÃO marque** "Initialize this repository with:"
	 - ❌ README
	 - ❌ .gitignore
	 - ❌ license
3. Clique em **"Create repository"**

4. Na página de instruções, copie o comando e execute:
   ```powershell
   # Substituir SEU-USUARIO pelo seu username do GitHub
   git remote add origin https://github.com/SEU-USUARIO/desenvolvimento-pessoas.git
   git push -u origin main
   ```

5. Aguarde o push completar (~1-2 minutos dependendo da conexão)

### Opção B: Via GitHub CLI (Avançado)

Se você tem o GitHub CLI instalado:

```powershell
# Instalar GitHub CLI (se não tiver)
winget install GitHub.cli

# Login no GitHub
gh auth login

# Criar repositório e fazer push
gh repo create desenvolvimento-pessoas --private --source=. --push
```

---

## 🎨 PASSO 3: CRIAR CONTA NO RENDER.COM

### 3.1 Acessar Render

1. Acesse: https://render.com
2. Clique em **"Get Started for Free"** ou **"Sign Up"**

### 3.2 Fazer Sign Up

**Opção Recomendada: Login com GitHub**
1. Clique em **"Sign up with GitHub"**
2. Autorize Render a acessar suas informações básicas
3. Render pedirá acesso aos seus repositórios:
   - Pode escolher "All repositories" ou "Select repositories"
   - Selecione `desenvolvimento-pessoas`
4. Clique em **"Install & Authorize"**

**Opção Alternativa: Email**
1. Clique em **"Sign up with Email"**
2. Preencha nome, email e senha
3. Confirme email (checar caixa de entrada)
4. Depois conecte sua conta GitHub:
   - Settings → Connected Accounts → GitHub → Connect

### 3.3 Completar Perfil

- Não é necessário adicionar cartão de crédito para free tier
- Preencha informações básicas se solicitado

---

## 🚢 PASSO 4: FAZER DEPLOY NO RENDER

### 4.1 Criar Blueprint (Infraestrutura)

1. No dashboard do Render, clique em **"New +"** (canto superior direito)
2. Selecione **"Blueprint"**
3. Conecte seu repositório:
   - Se ainda não conectou o GitHub: clique em "Connect GitHub"
   - Procure por `desenvolvimento-pessoas`
   - Clique em **"Connect"**

4. Render lerá o arquivo `render.yaml` automaticamente
5. Você verá a preview dos recursos que serão criados:
   ```
   ✅ Web Service: desenvolvimento-pessoas-api
	  - Type: Docker
	  - Plan: Free
	  - Region: Oregon

   ✅ PostgreSQL Database: desenvolvimento-pessoas-db
	  - Plan: Free (500 MB)
	  - Region: Oregon
   ```

6. Clique em **"Apply"** para criar os recursos

### 4.2 Aguardar Deploy

**O que acontece durante o deploy:**

1. **Cloning repository** (~10-20s)
   - Render clona seu repositório do GitHub

2. **Building Docker image** (~5-8 min)
   - Executa comandos do Dockerfile
   - Restaura pacotes .NET
   - Compila a aplicação
   - ⏳ Esta é a parte mais demorada

3. **Pushing image** (~1-2 min)
   - Salva imagem no registry do Render

4. **Starting service** (~30-60s)
   - Inicia a aplicação
   - Aplica migrations do banco de dados
   - Executa health check

5. **Deploy Live** ✅
   - Aplicação disponível publicamente

**Status esperado:**
- 🔵 **Building** → 🟡 **Deploying** → 🟢 **Live**

### 4.3 Monitorar Logs (Opcional)

Durante o deploy, clique no serviço `desenvolvimento-pessoas-api` para ver logs em tempo real:

```
==> Building Docker image...
#1 [internal] load build definition from Dockerfile
#2 [internal] load .dockerignore
...
==> Downloading cached image
==> Building image...
...
✅ Database migrations applied successfully
info: Microsoft.Hosting.Lifetime[14]
	  Now listening on: http://[::]:8080
info: Microsoft.Hosting.Lifetime[0]
	  Application started. Press Ctrl+C to shut down.
```

---

## ✅ PASSO 5: VALIDAR DEPLOY

### 5.1 Obter URL da Aplicação

Após deploy concluído (**Live**):

1. No dashboard, clique no serviço `desenvolvimento-pessoas-api`
2. No topo da página, você verá a URL:
   ```
   https://desenvolvimento-pessoas-api.onrender.com
   ```
3. Copie esta URL

### 5.2 Testar Endpoints

**Health Check:**
```powershell
$url = "https://desenvolvimento-pessoas-api.onrender.com"

# Primeira requisição (pode levar ~30s se estava dormindo)
Invoke-RestMethod -Uri "$url/health"
# Esperado: { "status": "ok" }
```

**Swagger UI:**
Abra no navegador:
```
https://desenvolvimento-pessoas-api.onrender.com/swagger
```

Deve mostrar a documentação interativa completa da API.

**Criar Usuário Master:**
```powershell
$body = @{
	email = "admin@exemplo.com"
	password = "Admin@123456"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$url/api/admin/ensure" -Method POST -Body $body -ContentType "application/json"
```

### 5.3 Verificar Banco de Dados

1. No dashboard do Render
2. Clique em **"desenvolvimento-pessoas-db"** (PostgreSQL)
3. Na aba **"Info"**:
   - **Status:** Available
   - **Current Storage:** ~10-20 MB (inicial)
   - **Connection Info:** Clique em "Show" para ver credenciais

---

## 🔄 PASSO 6: FAZER ATUALIZAÇÕES (REDEPLOY)

### 6.1 Fluxo de Atualização

Após fazer mudanças no código:

```powershell
# 1. Fazer alterações nos arquivos
# ...

# 2. Commit das mudanças
git add .
git commit -m "feat: adicionar novo endpoint de relatórios"

# 3. Push para GitHub
git push origin main
```

**Deploy Automático:**
- Render detecta o push automaticamente
- Inicia novo build e deploy (~5-10 min)
- Aplicação é atualizada sem downtime

### 6.2 Monitorar Redeploy

No dashboard do Render:
- Vá em `desenvolvimento-pessoas-api`
- Aba **"Events"** mostra histórico de deploys
- Aba **"Logs"** mostra logs em tempo real

---

## 📊 PASSO 7: MONITORAMENTO E LOGS

### 7.1 Ver Logs em Tempo Real

No dashboard do Render:
1. Clique no serviço `desenvolvimento-pessoas-api`
2. Aba **"Logs"**
3. Logs aparecem em tempo real

Filtragem:
- **All logs** - Todos os logs
- **Error** - Apenas erros
- **Warning** - Avisos
- **Info** - Informações

### 7.2 Métricas (Free Tier)

Aba **"Metrics"**:
- **CPU Usage** - Uso de CPU (%)
- **Memory Usage** - Uso de memória (MB)
- **HTTP Requests** - Requisições por minuto
- **Response Time** - Tempo de resposta (ms)

### 7.3 Comandos Úteis

**Ver status do serviço:**
```powershell
# Instalar Render CLI (opcional)
npm install -g @render/cli

# Login
render login

# Ver serviços
render services

# Ver logs
render logs desenvolvimento-pessoas-api
```

---

## 🔧 CONFIGURAÇÕES AVANÇADAS

### Variáveis de Ambiente Adicionais

No dashboard → `desenvolvimento-pessoas-api` → aba **"Environment"**:

**OpenAI (Chat AI):**
```
OpenAI__ApiKey = sk-proj-...
OpenAI__Model = gpt-4
```

**Stripe (Pagamentos):**
```
Stripe__SecretKey = sk_test_...
Stripe__PublishableKey = pk_test_...
```

Após adicionar, clique em **"Save Changes"** → Aplicação redeploya automaticamente.

### Custom Domain (Opcional)

1. Compre um domínio (ex: `minhaplataforma.com.br`)
2. No Render: Serviço → aba **"Settings"** → **"Custom Domain"**
3. Adicione: `api.minhaplataforma.com.br`
4. Configure DNS no seu provedor:
   ```
   Type: CNAME
   Name: api
   Value: desenvolvimento-pessoas-api.onrender.com
   ```
5. Aguarde propagação DNS (~5-60 min)
6. Render provisiona SSL automaticamente

### Evitar Sleep (Ping Automático)

Render free tier "dorme" após 15 min de inatividade. Para manter ativo:

**Opção 1: Usar serviço externo de ping**
- https://cron-job.org (gratuito)
- Configurar para acessar `https://seu-app.onrender.com/health` a cada 10 minutos

**Opção 2: GitHub Actions (dentro do mesmo repositório)**

Criar arquivo `.github/workflows/keep-alive.yml`:
```yaml
name: Keep Render App Alive
on:
  schedule:
	- cron: '*/10 * * * *'  # A cada 10 minutos
  workflow_dispatch:

jobs:
  ping:
	runs-on: ubuntu-latest
	steps:
	  - name: Ping Render App
		run: curl -I https://desenvolvimento-pessoas-api.onrender.com/health
```

---

## 🐛 TROUBLESHOOTING

### ❌ "Build falhou"

**Sintomas:**
- Deploy trava em "Building"
- Logs mostram erro de build

**Soluções:**

1. **Verificar Dockerfile:**
   ```powershell
   # Testar build localmente
   docker build -t test-build -f Dockerfile .
   ```

2. **Verificar logs de build no Render:**
   - Procurar por linhas com `ERROR` ou `FAILED`
   - Geralmente relacionado a pacotes NuGet ou referências

3. **Limpar cache e rebuild:**
   - No Render: Serviço → Settings → **"Clear build cache & deploy"**

### ❌ "Application não inicia"

**Sintomas:**
- Build completa mas aplicação não fica "Live"
- Logs mostram crash loop

**Soluções:**

1. **Verificar porta:**
   - Dockerfile DEVE expor porta 8080
   - `ENV ASPNETCORE_URLS=http://+:8080`

2. **Verificar migrations:**
   - Logs devem mostrar: `✅ Database migrations applied successfully`
   - Se não: problema na connection string do PostgreSQL

3. **Verificar memória:**
   - Free tier tem 512 MB de RAM
   - Aplicação pode estar usando mais que isso
   - Ver logs: `OOMKilled` indica falta de memória

### ❌ "Database connection failed"

**Sintomas:**
- Logs mostram: `Unable to connect to database`
- Aplicação crashando repetidamente

**Soluções:**

1. **Verificar se database foi criado:**
   - Dashboard → deve ter `desenvolvimento-pessoas-db` com status "Available"

2. **Verificar connection string:**
   - Serviço → Environment → `ConnectionStrings__DefaultConnection`
   - Deve estar configurada automaticamente pelo render.yaml

3. **Testar conexão manual:**
   - No dashboard do database → aba "Info" → copiar credenciais
   - Usar ferramenta como DBeaver ou pgAdmin

### ❌ "502 Bad Gateway"

**Sintomas:**
- Ao acessar URL, retorna erro 502
- Aplicação estava funcionando antes

**Causas:**
- Aplicação "dormiu" (free tier)
- Primeira requisição pode demorar 30-60s

**Solução:**
- Aguardar 30-60 segundos e tentar novamente
- Se persistir: ver logs para identificar erro interno

### ❌ "SSL certificate error"

**Sintomas:**
- Navegador mostra aviso de SSL inválido
- HTTPS não funciona

**Solução:**
- Render provisiona SSL automaticamente
- Pode levar 1-5 minutos após primeiro deploy
- Se persistir após 10 minutos: contatar suporte do Render

---

## 💰 GERENCIAR CUSTOS (Free Tier)

### Monitorar Uso

Dashboard → Account → aba **"Usage"**:
- **Service Hours** - Horas consumidas (limite: 750h/mês)
- **Bandwidth** - Tráfego de dados (limite: 100 GB/mês)
- **Builds** - Número de builds (ilimitado no free tier)

### Limites do Free Tier

| Recurso | Limite Gratuito |
|---------|----------------|
| Service Hours | 750 horas/mês |
| Bandwidth | 100 GB/mês |
| PostgreSQL Storage | 500 MB |
| PostgreSQL Backup | 90 dias |
| Build Time | Ilimitado |
| SSL Certificates | Incluído |
| Custom Domains | Incluído |

### Otimizar Uso

1. **Sleep Automático:**
   - Deixar aplicação dormir após 15 min economiza horas

2. **Minimizar Requests:**
   - Cada request "acorda" a aplicação
   - Agrupar chamadas de API quando possível

3. **Limpar Database:**
   - Remover dados antigos periodicamente
   - Manter storage abaixo de 400 MB

---

## 🗑️ REMOVER RECURSOS (Cleanup)

### Deletar Serviço

1. Dashboard → `desenvolvimento-pessoas-api`
2. Settings → **"Delete Web Service"**
3. Digite o nome do serviço para confirmar
4. Clique em **"Delete"**

### Deletar Database

1. Dashboard → `desenvolvimento-pessoas-db`
2. Settings → **"Delete PostgreSQL"**
3. ⚠️ **ATENÇÃO:** Todos os dados serão perdidos permanentemente
4. Digite o nome para confirmar
5. Clique em **"Delete"**

### Desconectar GitHub

1. Settings → Connected Accounts
2. GitHub → **"Disconnect"**

---

## 📚 RECURSOS E REFERÊNCIAS

### Documentação Oficial
- **Render Docs:** https://render.com/docs
- **Render Free Tier:** https://render.com/docs/free
- **Deploy Docker:** https://render.com/docs/docker
- **PostgreSQL:** https://render.com/docs/databases

### Comunidade
- **Render Community:** https://community.render.com
- **Status Page:** https://status.render.com
- **Support:** https://render.com/support

### Ferramentas Úteis
- **Render CLI:** https://github.com/render-oss/cli
- **Docker Desktop:** https://www.docker.com/products/docker-desktop
- **GitHub CLI:** https://cli.github.com
- **Postman:** https://www.postman.com

---

## ✅ CHECKLIST FINAL

### Deploy Bem-Sucedido

- [ ] Repositório GitHub criado e código enviado
- [ ] Conta Render.com criada e GitHub conectado
- [ ] Blueprint aplicado com sucesso
- [ ] Web service status: **Live** 🟢
- [ ] Database status: **Available** 🟢
- [ ] Health check retorna `{"status":"ok"}`
- [ ] Swagger UI acessível
- [ ] Usuário master criado via `/api/admin/ensure`
- [ ] URL pública salva em local seguro

### Opcional (Produção)

- [ ] Custom domain configurado
- [ ] Variáveis de ambiente (OpenAI, Stripe) configuradas
- [ ] Keep-alive configurado (evitar sleep)
- [ ] Backup manual do database agendado (a cada 30 dias)
- [ ] Monitoramento configurado (logs, métricas)

---

**🎉 Parabéns! Sua plataforma está online gratuitamente no Render.com!**

**Criado por:** Guia de Deploy Render.com  
**Última atualização:** 2025-06-01  
**Versão:** 1.0
