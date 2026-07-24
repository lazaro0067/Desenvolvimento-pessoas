namespace Desenvolvimento.Services.AI
{
    public interface IAgentService
    {
        /// <summary>
        /// Envia uma mensagem para o agente de IA e retorna a resposta.
        /// Implementação concreta deve integrar com OpenAI/Azure/Open-source provider.
        /// </summary>
        Task<string> SendMessageAsync(string userId, string message);
    }
}
