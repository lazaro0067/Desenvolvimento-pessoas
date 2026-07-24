using System;

namespace Desenvolvimento.Core.Models
{
    public class Curriculum
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid UserId { get; set; }
        public string? Title { get; set; }
        public string? Content { get; set; }
    }
}
