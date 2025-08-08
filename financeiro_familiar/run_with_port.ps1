# Script PowerShell para executar o projeto Flutter com porta específica
# Uso: .\run_with_port.ps1 [porta]

param(
    [int]$Port = 8080
)

Write-Host "Executando Flutter na porta $Port..." -ForegroundColor Green

try {
    flutter run -d chrome --web-port=$Port
}
catch {
    Write-Host "Erro ao executar o Flutter: $_" -ForegroundColor Red
    exit 1
}