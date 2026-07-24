using System;

namespace Desenvolvimento.Core.Models
{
    public class Profile
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid UserId { get; set; }
        public string? Summary { get; set; }
        public string? Keywords { get; set; }
    }
}
