$ErrorActionPreference = "Stop"

$processNames = @(
    "FactoryAutomation.Api",
    "FactoryAutomation.Worker",
    "FactoryAutomation.Blazor"
)

Write-Host "FactoryAutomation 프로세스 종료를 시작합니다."

foreach ($processName in $processNames) {
    $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if (-not $processes) {
        Write-Host "실행 중인 프로세스 없음: $processName"
        continue
    }

    foreach ($process in $processes) {
        Write-Host "종료 중: $($process.ProcessName) / PID: $($process.Id)"
        Stop-Process -Id $process.Id -Force
    }
}

Write-Host "FactoryAutomation 프로세스 종료가 완료되었습니다."