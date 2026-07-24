using Desenvolvimento.Core.Models;
using Desenvolvimento.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Desenvolvimento.Services.AI
{
    public class AgentService : IAgentService
    {
        private readonly ApplicationDbContext _db;

        public AgentService(ApplicationDbContext db)
        {
            _db = db;
        }

        public async Task<string> SendMessageAsync(string userId, string message)
        {
            // Salvar mensagem do usuário
            var userMessage = new ChatMessage
            {
                UserId = Guid.Parse(userId),
                Role = "user",
                Content = message
            };
            _db.ChatMessages.Add(userMessage);
            await _db.SaveChangesAsync();

            // Simulação de resposta de IA (substituir por integração real com OpenAI/Azure)
            var responseContent = $"Resposta automática para: {message}";

            // Salvar resposta do assistente
            var assistantMessage = new ChatMessage
            {
                UserId = Guid.Parse(userId),
                Role = "assistant",
                Content = responseContent
            };
            _db.ChatMessages.Add(assistantMessage);
            await _db.SaveChangesAsync();

            return responseContent;
        }
    }
}
