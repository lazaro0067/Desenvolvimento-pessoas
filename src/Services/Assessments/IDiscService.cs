using Desenvolvimento.Core.Models;

namespace Desenvolvimento.Services.Assessments
{
    public interface IDiscService
    {
        // Recebe respostas e retorna um resultado sumarizado (D/I/S/C scores)
        Task<string> CalculateResultAsync(DiscAnswer answer);
    }
}
