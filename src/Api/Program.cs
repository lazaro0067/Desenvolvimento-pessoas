using Desenvolvimento.Infrastructure.Data;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// 1. Configuração do DbContext para PostgreSQL (Neon) com tratamento de Connection String
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

    // Tratamento para converter URLs do tipo postgresql:// em formato Npgsql/ADO.NET sem erro de porta
    if (!string.IsNullOrEmpty(connectionString) &&
       (connectionString.StartsWith("postgresql://") || connectionString.StartsWith("postgres://")))
    {
        var uri = new Uri(connectionString);
        var userInfo = uri.UserInfo.Split(':');
        var port = uri.Port > 0 ? uri.Port : 5432;

        connectionString = $"Host={uri.Host};Port={port};Database={uri.AbsolutePath.TrimStart('/')};Username={userInfo[0]};Password={userInfo[1]};SSL Mode=Require;Trust Server Certificate=true;";
    }

    options.UseNpgsql(connectionString);
});

// 2. Registro do serviço de Controllers (Necessário para evitar o erro InvalidOperationException no MapControllers)
builder.Services.AddControllers();

// 3. Configuração do Identity
builder.Services.AddIdentity<IdentityUser, IdentityRole>()
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddDefaultTokenProviders();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// 4. Criação automática do schema e tabelas no PostgreSQL (Neon) ao inicializar a aplicação
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    db.Database.EnsureCreated();
}

// 5. Middlewares do Swagger
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "API v1");
    c.RoutePrefix = "swagger";
});

// 6. Endpoints
app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.MapGet("/api/users", async (ApplicationDbContext db) =>
    await db.AppUsers.ToListAsync());

// Mapeamento dos Controllers da aplicação
app.MapControllers();

// Endpoint administrativo para garantir roles padrão
app.MapPost("/api/admin/ensure", async (IServiceProvider services) =>
{
    using var scope = services.CreateScope();
    var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
    var userManager = scope.ServiceProvider.GetRequiredService<UserManager<IdentityUser>>();

    string[] roles = new[] { "Master", "Consultor", "Cliente" };
    foreach (var r in roles)
    {
        if (!await roleManager.RoleExistsAsync(r))
            await roleManager.CreateAsync(new IdentityRole(r));
    }

    return Results.Ok(new { status = "roles e usuários garantidos" });
});

app.Run();