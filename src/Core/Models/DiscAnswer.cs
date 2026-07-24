using System;
using System.Collections.Generic;

namespace Desenvolvimento.Core.Models
{
    public class DiscAnswer
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid UserId { get; set; }
        public Dictionary<string, int>? Answers { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
