using Desenvolvimento.Core.Models;

namespace Desenvolvimento.Services.Assessments
{
    public class DiscService : IDiscService
    {
        public Task<string> CalculateResultAsync(DiscAnswer answer)
        {
            // Implementação simplificada: soma os valores por chave e gera string
            if (answer.Answers == null || answer.Answers.Count == 0)
                return Task.FromResult("{\"D\":0,\"I\":0,\"S\":0,\"C\":0}");

            // Exemplo: as chaves podem ser "D","I","S","C" com valores
            int d = answer.Answers.TryGetValue("D", out var dv) ? dv : 0;
            int i = answer.Answers.TryGetValue("I", out var iv) ? iv : 0;
            int s = answer.Answers.TryGetValue("S", out var sv) ? sv : 0;
            int c = answer.Answers.TryGetValue("C", out var cv) ? cv : 0;

            var result = $"{{\"D\":{d},\"I\":{i},\"S\":{s},\"C\":{c}}}";
            return Task.FromResult(result);
        }
    }
}