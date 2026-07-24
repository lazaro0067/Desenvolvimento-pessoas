# Desenvolvimento de Pessoas - Plataforma Completa

Esta plataforma oferece consultorias digitais com ferramentas de desenvolvimento, avaliações, trilhas e IA.

## Estrutura

- src/Core - Modelos
- src/Infrastructure - EF Core + Identity
- src/Api - REST API
- src/Web - Blazor Admin
- src/Services - IA, Pagamentos
- Impulsionar - MAUI Mobile

## Funcionalidades

- Autenticação (Master/Consultor/Cliente)
- DISC, PDI, Avaliações
- Perfis e Currículos
- Cursos e Trilhas
- Chat IA
- Pagamentos/Assinaturas
- Compartilhamento Social

## Start

1. Criar banco: `dotnet ef database update --project src/Infrastructure`
2. Rodar API: `cd src/Api && dotnet run`
3. Inicializar: POST /api/admin/ensure
4. Master: master@exemplo.local / Pass@12345

## Integrações

- IA: Substituir AgentService por OpenAI/Azure
- Pagamento: Stripe/PayPal no PaymentService
- Storage: Azure Blob/S3 para vídeos
