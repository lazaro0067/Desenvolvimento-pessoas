# 📋 INSTRUÇÕES DE DEPLOY - PÁGINA ÚNICA

**Plataforma: Desenvolvimento de Pessoas**  
**Ambiente: Render.com Free Tier**  
**Data: 24/07/2026**

---

## ✅ PRÉ-REQUISITOS

| Item | Status | Link |
|------|--------|------|
| Git | ⬜ | https://git-scm.com/download/win |
| Conta GitHub | ⬜ | https://github.com/signup |
| Conta Render | ⬜ | https://render.com |

---

## 🚀 COMANDOS SEQUENCIAIS

### 1️⃣ Verificar Setup
```powershell
cd 'C:\Users\Lázaro\source\repos\Desenvolvimento de pessoas'
.\deploy-render.ps1 -CheckOnly
```
**Resultado esperado:** ✅ TODOS OS REQUISITOS ATENDIDOS!

---

### 2️⃣ Inicializar Git
```powershell
.\deploy-render.ps1 -InitGit
```
**Resultado:** Repositório Git criado

---

### 3️⃣ Criar Repositório GitHub

**Via GitHub Desktop (Recomendado):**
```
1. Baixar: https://desktop.github.com/
2. File → Add Local Repository
3. Selecionar: C:\Users\Lázaro\source\repos\Desenvolvimento de pessoas
4. Publish Repository → Privado ✅
```

**Via Linha de Comando:**
```powershell
# 1. Criar repo: https://github.com/new
# Nome: desenvolvimento-pessoas

# 2. Conectar (substituir SEU_USUARIO):
git remote add origin https://github.com/SEU_USUARIO/desenvolvimento-pessoas.git
git branch -M main
git push -u origin main
```

---

### 4️⃣ Deploy no Render

**No navegador:**
```
1. https://dashboard.render.com
2. Sign up com GitHub
3. New + → Blueprint
4. Selecionar: desenvolvimento-pessoas
5. Apply
6. Aguardar ~5-10 minutos
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

## 🔗 URLS IMPORTANTES

| Ambiente | URL |
|----------|-----|
| **Render Dashboard** | https://dashboard.render.com |
| **GitHub** | https://github.com |
| **API Produção** | https://desenvolvimento-pessoas-api.onrender.com |
| **Health Prod** | https://desenvolvimento-pessoas-api.onrender.com/health |
| **Swagger Prod** | https://desenvolvimento-pessoas-api.onrender.com/swagger |
| **API Local** | http://localhost:5000 |
| **Swagger Local** | http://localhost:5000/swagger |

---

## 🆘 TROUBLESHOOTING RÁPIDO

| Problema | Solução |
|----------|---------|
| Git não reconhecido | Instalar: https://git-scm.com/download/win |
| 502 Bad Gateway | Aguardar 30s (cold start) |
| Build Failed | Verificar logs no Render Dashboard |
| Push Failed | `git push -u origin main` |

---

## 🔄 ATUALIZAÇÕES FUTURAS

```powershell
# Commit e deploy automático
.\deploy-render.ps1 -CommitAndPush -CommitMessage "feat: nova funcionalidade"
```

---

## 📊 CUSTOS

**Free Tier:** R$ 0,00/mês ✅
- Web Service: 512 MB RAM
- PostgreSQL: 1 GB
- SSL incluído
- Auto-deploy

**Upgrade (Futuro):** ~R$ 70/mês
- Sem sleep
- Melhor performance

---

## 📚 DOCUMENTAÇÃO

| Arquivo | Descrição |
|---------|-----------|
| README.md | Overview completo |
| QUICKSTART_RENDER.md | Deploy 5 minutos |
| DEPLOY_RENDER_PASSO_A_PASSO.md | Guia detalhado |
| STATUS_DEPLOY.md | Status atual |
| RENDER_LIMITS.md | Limitações free tier |
| POSTGRESQL_GUIDE.md | Guia do banco |

---

## ✅ CHECKLIST DE DEPLOY

- [ ] Git instalado
- [ ] `.\deploy-render.ps1 -CheckOnly` OK
- [ ] `.\deploy-render.ps1 -InitGit` executado
- [ ] Repositório GitHub criado
- [ ] Código enviado (git push)
- [ ] Conta Render criada
- [ ] Blueprint aplicado
- [ ] Deploy concluído
- [ ] Health check testado
- [ ] Swagger acessível

---

**🎉 SUCESSO! API online em https://desenvolvimento-pessoas-api.onrender.com**

---

*Imprimir esta página para referência rápida*
