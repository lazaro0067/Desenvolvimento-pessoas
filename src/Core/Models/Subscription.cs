using System;

namespace Desenvolvimento.Core.Models
{
    public class Subscription
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid UserId { get; set; }
        public string? Plan { get; set; } // Basic, Premium, Enterprise
        public DateTime StartDate { get; set; } = DateTime.UtcNow;
        public DateTime? EndDate { get; set; }
        public bool IsActive { get; set; } = true;
        public string? PaymentId { get; set; } // ID do pagamento externo (Stripe/PayPal)
    }
}
