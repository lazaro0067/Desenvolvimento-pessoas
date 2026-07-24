using System;

namespace Desenvolvimento.Core.Models
{
    public class UserPermission
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid UserId { get; set; }
        public string? Feature { get; set; } // DISC, PDI, Courses, etc.
        public bool IsEnabled { get; set; } = false;
        public DateTime? EnabledAt { get; set; }
        public string? EnabledBy { get; set; } // Master user ID
    }
}
