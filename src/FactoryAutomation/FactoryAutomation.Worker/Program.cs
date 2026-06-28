using FactoryAutomation.Worker;

var builder = Host.CreateApplicationBuilder(args);
builder.Services.AddHostedService<Worker>();

if (OperatingSystem.IsWindows())
{
    builder.Configuration.AddJsonFile("appsettings.Windows.json", optional: true);
}
else if (OperatingSystem.IsLinux())
{
    builder.Configuration.AddJsonFile("appsettings.Linux.json", optional: true);
}

var host = builder.Build();
host.Run();
