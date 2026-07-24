using Desenvolvimento.Infrastructure.Data;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Configuração do DbContext para PostgreSQL (Neon)
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Identity
builder.Services.AddIdentity<IdentityUser, IdentityRole>()
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddDefaultTokenProviders();

// Registrar serviços (comentados temporariamente até o namespace/projeto de serviços ser vinculado)
// builder.Services.AddScoped<IDiscService, DiscService>();
// builder.Services.AddScoped<IAgentService, AgentService>();
// builder.Services.AddScoped<IPaymentService, PaymentService>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Habilita o Swagger em qualquer ambiente (Desenvolvimento e Produção)
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "API v1");
    c.RoutePrefix = "swagger";
});

app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.MapGet("/api/users", async (ApplicationDbContext db) =>
    await db.AppUsers.ToListAsync());

// Endpoint para inicializar roles e criar usuário master (apenas para desenvolvimento)
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