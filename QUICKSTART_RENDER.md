# 🚀 Quick Start: Deploy em 5 Minutos

## 📋 Pré-requisitos

- [ ] Git instalado → https://git-scm.com/download/win
- [ ] Conta GitHub → https://github.com/signup
- [ ] Conta Render → https://render.com (use login do GitHub)

---

## ⚡ Comandos Rápidos

### 1️⃣ Verificar Requisitos

```powershell
.\deploy-render.ps1 -CheckOnly
```

**Resultado esperado:**
```
✅ Git instalado
✅ .NET SDK instalado
✅ Arquivos críticos OK
✅ TODOS OS REQUISITOS ATENDIDOS!
```

---

### 2️⃣ Inicializar Git

```powershell
.\deploy-render.ps1 -InitGit
```

**O que faz:**
- Cria repositório Git local
- Cria `.gitignore`
- Faz primeiro commit

---

### 3️⃣ Criar Repositório GitHub

**Opção A: GitHub Desktop (Recomendado)**

1. Baixe: https://desktop.github.com/
2. File → Add Local Repository
3. Selecione a pasta do projeto
4. Publish Repository → Privado ✅

**Opção B: Linha de Comando**

```powershell
# 1. Crie repo no GitHub: https://github.com/new
# Nome sugerido: desenvolvimento-pessoas

# 2. Conecte (substitua SEU_USUARIO):
git remote add origin https://github.com/SEU_USUARIO/desenvolvimento-pessoas.git
git branch -M main
git push -u origin main
```

---

### 4️⃣ Deploy no Render

**No navegador:**

1. **Acesse:** https://dashboard.render.com
2. **Login** com GitHub
3. **New +** → **Blueprint**
4. **Selecione** seu repositório `desenvolvimento-pessoas`
5. **Apply** (Render detecta `render.yaml` automaticamente)
6. **Aguarde** ~5-10 minutos

**URLs após deploy:**
```
🌐 API:     https://desenvolvimento-pessoas-api.onrender.com
❤️  Health: https://desenvolvimento-pessoas-api.onrender.com/health
📖 Swagger: https://desenvolvimento-pessoas-api.onrender.com/swagger
```

---

### 5️⃣ Testar

```powershell
# Health Check
Invoke-RestMethod https://desenvolvimento-pessoas-api.onrender.com/health

# Abrir Swagger
Start-Process https://desenvolvimento-pessoas-api.onrender.com/swagger
```

---

## 🔄 Atualizações Futuras

Sempre que modificar o código:

```powershell
.\deploy-render.ps1 -CommitAndPush -CommitMessage "feat: nova funcionalidade"
```

**Render faz deploy automático!** 🎉

---

## 💡 Dicas

### Keep-Alive (Evitar Sleep)

Crie `.github/workflows/keep-alive.yml`:

```yaml
name: Keep Alive
on:
  schedule:
	- cron: '*/14 * * * *'
  workflow_dispatch:
jobs:
  ping:
	runs-on: ubuntu-latest
	steps:
	  - run: curl -f https://desenvolvimento-pessoas-api.onrender.com/health || exit 0
```

### Monitorar

- **Logs:** https://dashboard.render.com → Logs
- **Métricas:** CPU, RAM, requests
- **Banco:** https://dashboard.render.com → Database

### Troubleshooting

| Problema | Solução |
|----------|---------|
| 502 Bad Gateway | Aguarde 30s (cold start) |
| Build Failed | Verifique logs no Render |
| Lento | Normal no free tier (use keep-alive) |

---

## 📚 Documentação Completa

- 📘 `DEPLOY_RENDER_PASSO_A_PASSO.md` - Guia detalhado
- 📘 `RENDER_DEPLOY.md` - Deploy completo
- 📘 `RENDER_LIMITS.md` - Limites free tier
- 📘 `POSTGRESQL_GUIDE.md` - Banco de dados
- 📘 `ACESSO_RENDER.md` - URLs e endpoints

---

## ✅ Checklist

- [ ] Git instalado
- [ ] `.\deploy-render.ps1 -CheckOnly` passa
- [ ] `.\deploy-render.ps1 -InitGit` executado
- [ ] Repositório GitHub criado e conectado
- [ ] Código enviado (`git push`)
- [ ] Blueprint aplicado no Render
- [ ] Health check funcionando
- [ ] Swagger acessível

---

## 🎯 Próximos Passos

1. **Domínio customizado** (opcional)
   - Render → Settings → Custom Domain
   - Exemplo: `api.seudominio.com.br`

2. **Upgrade para Paid** (quando necessário)
   - $7/mês = sem sleep + melhor performance
   - 1 GB RAM

3. **CI/CD avançado**
   - Tests automáticos
   - Múltiplos ambientes (staging/prod)

---

**🚀 Pronto! Deploy em 5 minutos!**

Dúvidas? Consulte `DEPLOY_RENDER_PASSO_A_PASSO.md`
