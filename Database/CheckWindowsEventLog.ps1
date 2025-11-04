# =============================================
# Script para revisar el Event Log de Windows
# Ejecutar en PowerShell como Administrador
# =============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "REVISANDO WINDOWS EVENT LOG" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Obtener los últimos errores de SQL Server del Application Log
Write-Host "Errores recientes de SQL Server (últimos 10):" -ForegroundColor Yellow
Get-EventLog -LogName Application -Source "MSSQL*" -EntryType Error -Newest 10 |
    Format-Table TimeGenerated, Source, Message -AutoSize -Wrap

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Errores relacionados con BACKUP:" -ForegroundColor Yellow
Get-EventLog -LogName Application -Source "MSSQL*" -Newest 50 |
    Where-Object { $_.Message -like "*BACKUP*" } |
    Format-List TimeGenerated, Source, EntryType, Message

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
