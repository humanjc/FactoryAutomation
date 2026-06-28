param(
    [string]$PublishRoot = $PSScriptRoot,
    [string]$ApiUrl = "http://0.0.0.0:5000",
    [string]$BlazorUrl = "http://0.0.0.0:5001"
)

$ErrorActionPreference = "Stop"

$apiExe = Join-Path $PublishRoot "FactoryAutomation.Api\FactoryAutomation.Api.exe"
$workerExe = Join-Path $PublishRoot "FactoryAutomation.Worker\FactoryAutomation.Worker.exe"
$blazorExe = Join-Path $PublishRoot "FactoryAutomation.Blazor\FactoryAutomation.Blazor.exe"

function Test-Executable {
    param(
        [string]$Path,
        [string]$Name
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Name 실행 파일을 찾을 수 없습니다: $Path"
    }
}

function Start-AppWindow {
    param(
        [string]$Title,
        [string]$ExePath,
        [string[]]$Arguments = @()
    )

    $workingDirectory = Split-Path -Parent $ExePath
    $argumentText = ($Arguments | ForEach-Object { '"' + $_ + '"' }) -join " "

    $command = @"
`$Host.UI.RawUI.WindowTitle = '$Title'
Set-Location -LiteralPath '$workingDirectory'
& '$ExePath' $argumentText
#Read-Host '종료하려면 Enter를 누르세요'
"@

    Start-Process powershell.exe -ArgumentList @(
        "-NoExit",
        "-ExecutionPolicy", "Bypass",
        "-Command", $command
    )
}

Test-Executable -Path $apiExe -Name "API"
Test-Executable -Path $workerExe -Name "Worker"
Test-Executable -Path $blazorExe -Name "Blazor"

Write-Host "FactoryAutomation 실행을 시작합니다."
Write-Host "API    : $ApiUrl"
Write-Host "Blazor : $BlazorUrl"
Write-Host "Root   : $PublishRoot"

Start-AppWindow -Title "FactoryAutomation API" -ExePath $apiExe -Arguments @("--urls", $ApiUrl)
Start-Sleep -Seconds 2

Start-AppWindow -Title "FactoryAutomation Worker" -ExePath $workerExe
Start-Sleep -Seconds 1

Start-AppWindow -Title "FactoryAutomation Blazor" -ExePath $blazorExe -Arguments @("--urls", $BlazorUrl)

Write-Host ""
Write-Host "브라우저에서 접속하세요: $BlazorUrl/production"
