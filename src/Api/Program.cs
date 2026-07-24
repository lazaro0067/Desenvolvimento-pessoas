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

// Registrar serviços
builder.Services.AddScoped<Desenvolvimento.Services.Assessments.IDiscService, Desenvolvimento.Services.Assessments.DiscService>();
builder.Services.AddScoped<Desenvolvimento.Services.AI.IAgentService, Desenvolvimento.Services.AI.AgentService>();
builder.Services.AddScoped<Desenvolvimento.Services.Payments.IPaymentService, Desenvolvimento.Services.Payments.PaymentService>();

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

    var masterEmail = "master@exemplo.local";
    var existing = await userManager.FindByEmailAsync(masterEmail);
    if (existing == null)
    {
        var master = new IdentityUser { UserName = masterEmail, Email = masterEmail, EmailConfirmed = true };
        var res = await userManager.CreateAsync(master, "Pass@12345");
        if (res.Succeeded)
        {
            await userManager.AddToRoleAsync(master, "Master");
        }
    }

    return Results.Ok(new { rolesInitialized = true });
});

// Registrar serviço DISC
builder.Services.AddScoped<Desenvolvimento.Services.Assessments.IDiscService, Desenvolvimento.Services.Assessments.DiscService>();

// Endpoint para submissão de questionário DISC
app.MapPost("/api/disc/submit", async (ApplicationDbContext db, Desenvolvimento.Services.Assessments.IDiscService discService, Desenvolvimento.Core.Models.DiscAnswer answer) =>
{
    // Salva as respostas
    db.DiscAnswers.Add(answer);
    await db.SaveChangesAsync();

    // Calcula resultado
    var result = await discService.CalculateResultAsync(answer);

    // Armazena como Assessment do tipo DISC
    var assessment = new Desenvolvimento.Core.Models.Assessment
    {
        UserId = answer.UserId,
        Type = "DISC",
        Result = result,
    };
    db.Assessments.Add(assessment);
    await db.SaveChangesAsync();

    return Results.Ok(new { assessmentId = assessment.Id, result });
});

// Cursos e trilhas (endpoints básicos)
app.MapGet("/api/courses", async (ApplicationDbContext db) => await db.Courses.ToListAsync());
app.MapPost("/api/courses", async (ApplicationDbContext db, Desenvolvimento.Core.Models.Course c) =>
{
    db.Courses.Add(c);
    await db.SaveChangesAsync();
    return Results.Created($"/api/courses/{c.Id}", c);
});

app.MapGet("/api/tracks", async (ApplicationDbContext db) => await db.Tracks.ToListAsync());
app.MapPost("/api/tracks", async (ApplicationDbContext db, Desenvolvimento.Core.Models.Track t) =>
{
    db.Tracks.Add(t);
    await db.SaveChangesAsync();
    return Results.Created($"/api/tracks/{t.Id}", t);
});

// CRUD básico para Profiles
app.MapGet("/api/profiles", async (ApplicationDbContext db) =>
    await db.Profiles.ToListAsync());

app.MapGet("/api/profiles/{id}", async (ApplicationDbContext db, Guid id) =>
    await db.Profiles.FindAsync(id) is var profile && profile != null ? Results.Ok(profile) : Results.NotFound());

app.MapPost("/api/profiles", async (ApplicationDbContext db, Desenvolvimento.Core.Models.Profile profile) =>
{
    db.Profiles.Add(profile);
    await db.SaveChangesAsync();
    return Results.Created($"/api/profiles/{profile.Id}", profile);
});

app.MapPut("/api/profiles/{id}", async (ApplicationDbContext db, Guid id, Desenvolvimento.Core.Models.Profile input) =>
{
    var existing = await db.Profiles.FindAsync(id);
    if (existing == null) return Results.NotFound();
    existing.Summary = input.Summary;
    existing.Keywords = input.Keywords;
    await db.SaveChangesAsync();
    return Results.NoContent();
});

app.MapDelete("/api/profiles/{id}", async (ApplicationDbContext db, Guid id) =>
{
    var existing = await db.Profiles.FindAsync(id);
    if (existing == null) return Results.NotFound();
    db.Profiles.Remove(existing);
    await db.SaveChangesAsync();
    return Results.NoContent();
});

// Endpoints básicos para Curriculums (CRUD minimal)
app.MapGet("/api/curriculums", async (ApplicationDbContext db) => await db.Curriculums.ToListAsync());
app.MapPost("/api/curriculums", async (ApplicationDbContext db, Desenvolvimento.Core.Models.Curriculum c) =>
{
    db.Curriculums.Add(c);
    await db.SaveChangesAsync();
    return Results.Created($"/api/curriculums/{c.Id}", c);
});

// Chat com agente de IA
app.MapPost("/api/chat", async (ApplicationDbContext db, Desenvolvimento.Services.AI.IAgentService agent, ChatRequest request) =>
{
    var response = await agent.SendMessageAsync(request.UserId, request.Message);
    return Results.Ok(new { response });
});

app.MapGet("/api/chat/history/{userId}", async (ApplicationDbContext db, string userId) =>
{
    var messages = await db.ChatMessages
        .Where(m => m.UserId == Guid.Parse(userId))
        .OrderBy(m => m.CreatedAt)
        .ToListAsync();
    return Results.Ok(messages);
});

// Pagamentos e assinaturas
app.MapPost("/api/checkout", async (Desenvolvimento.Services.Payments.IPaymentService payment, CheckoutRequest request) =>
{
    var sessionId = await payment.CreateCheckoutSessionAsync(request.UserId, request.Amount, request.Currency ?? "BRL");
    return Results.Ok(new { sessionId, url = $"https://checkout.exemplo.com/session/{sessionId}" });
});

app.MapPost("/api/subscriptions", async (ApplicationDbContext db, Desenvolvimento.Core.Models.Subscription sub) =>
{
    db.Subscriptions.Add(sub);
    await db.SaveChangesAsync();
    return Results.Created($"/api/subscriptions/{sub.Id}", sub);
});

app.MapGet("/api/subscriptions/{userId}", async (ApplicationDbContext db, Guid userId) =>
{
    var subs = await db.Subscriptions.Where(s => s.UserId == userId).ToListAsync();
    return Results.Ok(subs);
});

// Gerenciamento de permissões (Master)
app.MapPost("/api/permissions", async (ApplicationDbContext db, Desenvolvimento.Core.Models.UserPermission perm) =>
{
    db.UserPermissions.Add(perm);
    await db.SaveChangesAsync();
    return Results.Created($"/api/permissions/{perm.Id}", perm);
});

app.MapGet("/api/permissions/{userId}", async (ApplicationDbContext db, Guid userId) =>
{
    var perms = await db.UserPermissions.Where(p => p.UserId == userId).ToListAsync();
    return Results.Ok(perms);
});

// Compartilhamento social
app.MapPost("/api/share", async (ApplicationDbContext db, Desenvolvimento.Core.Models.SocialShare share) =>
{
    // Verificar permissão do usuário antes de permitir compartilhamento
    var permission = await db.UserPermissions
        .FirstOrDefaultAsync(p => p.UserId == share.UserId && p.Feature == share.ContentType && p.IsEnabled);

    if (permission == null)
        return Results.Unauthorized();

    db.SocialShares.Add(share);
    await db.SaveChangesAsync();
    return Results.Created($"/api/share/{share.Id}", share);
});

app.MapGet("/api/share/{userId}", async (ApplicationDbContext db, Guid userId) =>
{
    var shares = await db.SocialShares.Where(s => s.UserId == userId).ToListAsync();
    return Results.Ok(shares);
});

app.Run();

record ChatRequest(string UserId, string Message);
record CheckoutRequest(string UserId, decimal Amount, string? Currency);
