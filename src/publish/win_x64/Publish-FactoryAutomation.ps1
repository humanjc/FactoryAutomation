param(
    [string]$SolutionRoot = (Join-Path $PSScriptRoot "\..\..\FactoryAutomation"),
    [string]$PublishRoot = "D:\Learn\FAdotNet\src\publish\win_x64",
    [string]$Configuration = "Release",
    [string]$Runtime = "win-x64",
    [switch]$SelfContained
)

$ErrorActionPreference = "Stop"

$apiProject = Join-Path $SolutionRoot "FactoryAutomation.Api\FactoryAutomation.Api.csproj"
$workerProject = Join-Path $SolutionRoot "FactoryAutomation.Worker\FactoryAutomation.Worker.csproj"
$blazorProject = Join-Path $SolutionRoot "FactoryAutomation.Blazor\FactoryAutomation.Blazor.csproj"

$apiOutput = Join-Path $PublishRoot "FactoryAutomation.Api"
$workerOutput = Join-Path $PublishRoot "FactoryAutomation.Worker"
$blazorOutput = Join-Path $PublishRoot "FactoryAutomation.Blazor"

function Test-ProjectFile {
    param(
        [string]$Path,
        [string]$Name
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Name 프로젝트 파일을 찾을 수 없습니다: $Path"
    }
}

function Publish-Project {
    param(
        [string]$Name,
        [string]$ProjectPath,
        [string]$OutputPath
    )

    Write-Host ""
    Write-Host "Publishing $Name..."
    Write-Host "Project: $ProjectPath"
    Write-Host "Output : $OutputPath"

    $selfContainedValue = if ($SelfContained) { "true" } else { "false" }

    dotnet publish $ProjectPath `
        -c $Configuration `
        -r $Runtime `
        --self-contained $selfContainedValue `
        -o $OutputPath

    Write-Host "$Name publish complete."
}

Test-ProjectFile -Path $apiProject -Name "API"
Test-ProjectFile -Path $workerProject -Name "Worker"
Test-ProjectFile -Path $blazorProject -Name "Blazor"

Write-Host "FactoryAutomation publish start"
Write-Host "SolutionRoot : $SolutionRoot"
Write-Host "PublishRoot  : $PublishRoot"
Write-Host "Configuration: $Configuration"
Write-Host "Runtime      : $Runtime"
Write-Host "SelfContained: $SelfContained"

Publish-Project -Name "API" -ProjectPath $apiProject -OutputPath $apiOutput
Publish-Project -Name "Worker" -ProjectPath $workerProject -OutputPath $workerOutput
Publish-Project -Name "Blazor" -ProjectPath $blazorProject -OutputPath $blazorOutput

Write-Host ""
Write-Host "All projects published successfully."
Write-Host "Publish folder: $PublishRoot"