# 🚀 Guia de Publicação no Azure - Plataforma Desenvolvimento de Pessoas

## 📋 Pré-requisitos
- Cartão de crédito válido (não será cobrado no período gratuito)
- Conta Microsoft (Outlook, Hotmail ou criar nova)
- Acesso à internet

---

## 1️⃣ CRIAR CONTA AZURE GRATUITA

### Passo 1: Acessar Azure
1. Acesse: https://azure.microsoft.com/pt-br/free
2. Clique em **"Começar gratuitamente"** ou **"Experimente gratuitamente"**

### Passo 2: Fazer Login
1. Use sua conta Microsoft (Outlook/Hotmail)
2. OU clique em **"Criar uma"** para criar nova conta Microsoft

### Passo 3: Preencher Dados
1. **Informações pessoais**: Nome, email, telefone
2. **Verificação por SMS**: Receba código no celular
3. **Informações do cartão**: Necessário para verificação de identidade
   - ⚠️ **IMPORTANTE**: Você NÃO será cobrado automaticamente
   - Após 30 dias ou $200 de crédito, os serviços param até você ativar pagamento

### Passo 4: Concordar com Termos
1. Revise o contrato
2. Clique em **"Inscrever-se"**
3. Aguarde 2-3 minutos para criação da conta

### ✅ Conta Criada com Sucesso!
Você receberá:
- 💰 **$200 USD em créditos** (válidos por 30 dias)
- 🆓 **12 meses de serviços populares gratuitos**
- 💚 **Serviços sempre gratuitos** (dentro dos limites)

---

## 2️⃣ INSTALAR AZURE CLI (Linha de Comando)

### Windows (PowerShell como Administrador):
```powershell
# Baixar e instalar Azure CLI
winget install -e --id Microsoft.AzureCLI
```

**OU** baixe manualmente: https://aka.ms/installazurecliwindows

### Após Instalação:
```powershell
# Verificar instalação
az --version

# Fazer login na conta Azure
az login
```

O navegador abrirá automaticamente para você fazer login. Após login bem-sucedido, volte ao terminal.

---

## 3️⃣ RECURSOS GRATUITOS QUE USAREMOS

| Serviço | Tier Gratuito | Uso Mensal |
|---------|---------------|------------|
| **Azure Container Apps** | 180,000 vCPU-s + 360,000 GiB-s | Gratuito nos primeiros 2 milhões de requisições |
| **Azure Container Registry** | Basic: $5/mês (50 GB storage) | Primeiro mês grátis com crédito |
| **Azure SQL Database** | Basic: ~$5/mês (2 GB) | Primeiro mês grátis com crédito |

💡 **Estimativa de custo mensal após período gratuito**: ~$10-15 USD com tráfego baixo/médio

---

## 4️⃣ PRÓXIMOS PASSOS

Após criar sua conta Azure e instalar o Azure CLI, execute o script automatizado:

```powershell
# No diretório do projeto
.\deploy-azure.ps1
```

OU siga o guia manual completo em: **[DEPLOY_AZURE.md](DEPLOY_AZURE.md)**

---

## 🆘 PROBLEMAS COMUNS

### ❌ "Cartão de crédito recusado"
- Use cartão internacional (Visa, Mastercard)
- Alguns bancos virtuais podem não funcionar
- Tente cartão de débito internacional

### ❌ "Já tenho conta Azure mas expirou o free tier"
- Você precisará usar um cartão de crédito válido
- Os custos serão ~$10-15/mês para este projeto
- Ainda pode usar os $200 de crédito se não passaram 30 dias

### ❌ "Não consigo instalar Azure CLI"
- Baixe o instalador MSI manualmente: https://aka.ms/installazurecliwindows
- Execute como Administrador
- Reinicie o terminal após instalação

### 📞 Suporte Azure
- Portal: https://portal.azure.com
- Documentação: https://learn.microsoft.com/azure
- Suporte gratuito: https://azure.microsoft.com/support

---

## ✅ CHECKLIST ANTES DE CONTINUAR

- [ ] Conta Azure criada e ativa
- [ ] Azure CLI instalado (`az --version` funciona)
- [ ] Login feito com sucesso (`az login`)
- [ ] Créditos disponíveis visíveis no portal (https://portal.azure.com)

**Pronto?** Continue com o deploy automático! 🚀
