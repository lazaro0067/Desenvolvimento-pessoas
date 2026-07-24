using Desenvolvimento.Core.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Desenvolvimento.Infrastructure.Data
{
    // Usa IdentityDbContext para suportar ASP.NET Core Identity
    public class ApplicationDbContext : IdentityDbContext<IdentityUser, IdentityRole, string>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        // Entidades de domínio (renomeadas para evitar conflito com Identity)
        public DbSet<User> AppUsers { get; set; } = null!;
        public DbSet<Role> AppRoles { get; set; } = null!;
        public DbSet<Desenvolvimento.Core.Models.Profile> Profiles { get; set; } = null!;
        public DbSet<Desenvolvimento.Core.Models.Curriculum> Curriculums { get; set; } = null!;
        public DbSet<Desenvolvimento.Core.Models.Assessment> Assessments { get; set; } = null!;
        public DbSet<Desenvolvimento.Core.Models.Pdi> Pdis { get; set; } = null!;
        public DbSet<Desenvolvimento.Core.Models.DiscAnswer> DiscAnswers { get; set; } = null!;
        public DbSet<Desenvolvimento.Core.Models.Course> Courses { get; set; } = null!;
        public DbSet<Desenvolvimento.Core.Models.Track> Tracks { get; set; } = null!;
        public DbSet<Desenvolvimento.Core.Models.ChatMessage> ChatMessages { get; set; } = null!;
        public DbSet<Desenvolvimento.Core.Models.Subscription> Subscriptions { get; set; } = null!;
        public DbSet<Desenvolvimento.Core.Models.UserPermission> UserPermissions { get; set; } = null!;
        public DbSet<Desenvolvimento.Core.Models.SocialShare> SocialShares { get; set; } = null!;
    }
}
