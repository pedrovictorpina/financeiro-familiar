@echo off
REM Script para executar o projeto Flutter com porta específica
REM Uso: run_with_port.bat [porta]

set PORT=%1
if "%PORT%"=="" set PORT=8080

echo Executando Flutter na porta %PORT%...
flutter run -d chrome --web-port=%PORT%