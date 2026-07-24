using System;

namespace Desenvolvimento.Core.Models
{
    public class SocialShare
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid UserId { get; set; }
        public string? ContentType { get; set; } // Course, Assessment, Profile
        public Guid ContentId { get; set; }
        public string? Platform { get; set; } // Facebook, LinkedIn, Twitter
        public DateTime SharedAt { get; set; } = DateTime.UtcNow;
        public string? ShareUrl { get; set; }
    }
}
