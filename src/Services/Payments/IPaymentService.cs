namespace Desenvolvimento.Services.Payments
{
    public interface IPaymentService
    {
        /// <summary>
        /// Cria uma sessão de pagamento/checkout para o usuário.
        /// Implementação concreta deve integrar com Stripe/PayPal/PagSeguro.
        /// </summary>
        Task<string> CreateCheckoutSessionAsync(string userId, decimal amount, string currency = "BRL");
    }
}
