namespace FactoryAutomation.Shared;

public sealed record ProductionSnapshot(
    int Id,
    DateTime CreatedAt,
    string LineName,
    int GoodCount,
    int NgCount,
    string Status
);