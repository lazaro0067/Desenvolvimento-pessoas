using System;

namespace Desenvolvimento.Core.Models
{
    public class Pdi
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid UserId { get; set; }
        public string? Objectives { get; set; }
        public string? Actions { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
