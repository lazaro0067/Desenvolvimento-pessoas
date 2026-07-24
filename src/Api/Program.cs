using Desenvolvimento.Infrastructure.Data;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Configurar DbContext (string de conexão temporária - substituir em appsettings)
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection") ?? "Server=(localdb)\\mssqllocaldb;Database=DesenvPessoasDb;Trusted_Connection=True;"));

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

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

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