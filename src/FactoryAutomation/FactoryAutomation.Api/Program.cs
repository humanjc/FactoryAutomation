using FactoryAutomation.Shared;
using Microsoft.Data.Sqlite;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
});

if (OperatingSystem.IsWindows())
{
    builder.Configuration.AddJsonFile("appsettings.Windows.json", optional: true);
}
else if (OperatingSystem.IsLinux())
{
    builder.Configuration.AddJsonFile("appsettings.Linux.json", optional: true);
}

var app = builder.Build();

app.UseCors();

var dbPath = builder.Configuration["FactoryDatabase:Path"]
    ?? throw new InvalidOperationException("FactoryDatabase:Path 설정이 없습니다.");

app.MapGet("/api/production/latest", async () =>
{
    await using var connection = new SqliteConnection($"Data Source={dbPath}");
    await connection.OpenAsync();

    var command = connection.CreateCommand();
    command.CommandText = """
        SELECT Id, CreatedAt, LineName, GoodCount, NgCount, Status
        FROM ProductionSnapshots
        ORDER BY Id DESC
        LIMIT 1;
        """;

    await using var reader = await command.ExecuteReaderAsync();

    if (!await reader.ReadAsync())
    {
        return Results.NotFound();
    }

    var data = new ProductionSnapshot(
        reader.GetInt32(0),
        DateTime.Parse(reader.GetString(1)),
        reader.GetString(2),
        reader.GetInt32(3),
        reader.GetInt32(4),
        reader.GetString(5)
    );

    return Results.Ok(data);
});

app.Run();