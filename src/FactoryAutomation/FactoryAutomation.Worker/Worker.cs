using FactoryAutomation.Shared;
using Microsoft.Data.Sqlite;

namespace FactoryAutomation.Worker;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly string _dbPath;

    public Worker(ILogger<Worker> logger, IConfiguration configuration)
    {
        _logger = logger;

        _dbPath = configuration["FactoryDatabase:Path"]
            ?? throw new InvalidOperationException("FactoryDatabase:Path 설정이 없습니다.");
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(_dbPath)!);
        await InitializeDatabaseAsync();

        var random = new Random();
        var good = 0;
        var ng = 0;

        while (!stoppingToken.IsCancellationRequested)
        {
            var total = random.Next(5, 15);
            var defect = random.Next(0, 3);

            good += total - defect;
            ng += defect;

            var data = new ProductionSnapshot(
                0,
                DateTime.Now,
                "LINE-1",
                good,
                ng,
                defect >= 2 ? "Warning" : "Running"
            );

            await InsertAsync(data);
            _logger.LogInformation("Saved: Good={Good}, NG={Ng}, Status={Status}", good, ng, data.Status);

            await Task.Delay(TimeSpan.FromSeconds(2), stoppingToken);
        }
    }

    private async Task InitializeDatabaseAsync()
    {
        await using var connection = new SqliteConnection($"Data Source={_dbPath}");
        await connection.OpenAsync();

        var command = connection.CreateCommand();
        command.CommandText = """
            CREATE TABLE IF NOT EXISTS ProductionSnapshots (
                Id INTEGER PRIMARY KEY AUTOINCREMENT,
                CreatedAt TEXT NOT NULL,
                LineName TEXT NOT NULL,
                GoodCount INTEGER NOT NULL,
                NgCount INTEGER NOT NULL,
                Status TEXT NOT NULL
            );
            """;

        await command.ExecuteNonQueryAsync();
    }

    private async Task InsertAsync(ProductionSnapshot data)
    {
        await using var connection = new SqliteConnection($"Data Source={_dbPath}");
        await connection.OpenAsync();

        var command = connection.CreateCommand();
        command.CommandText = """
            INSERT INTO ProductionSnapshots
            (CreatedAt, LineName, GoodCount, NgCount, Status)
            VALUES ($createdAt, $lineName, $goodCount, $ngCount, $status);
            """;

        command.Parameters.AddWithValue("$createdAt", data.CreatedAt.ToString("O"));
        command.Parameters.AddWithValue("$lineName", data.LineName);
        command.Parameters.AddWithValue("$goodCount", data.GoodCount);
        command.Parameters.AddWithValue("$ngCount", data.NgCount);
        command.Parameters.AddWithValue("$status", data.Status);

        await command.ExecuteNonQueryAsync();
    }
}