using System;

namespace Desenvolvimento.Core.Models
{
    public class Role
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string? Name { get; set; }
        public string? Description { get; set; }
    }
}
