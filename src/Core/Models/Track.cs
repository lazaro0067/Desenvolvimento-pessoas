using System;
using System.Collections.Generic;

namespace Desenvolvimento.Core.Models
{
    public class Track
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string? Title { get; set; }
        public string? Description { get; set; }
        public List<Guid>? CourseIds { get; set; }
    }
}
