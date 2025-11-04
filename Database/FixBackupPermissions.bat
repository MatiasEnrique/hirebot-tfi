@echo off
echo ========================================
echo Configurando permisos de backup
echo ========================================
echo.

REM Crear directorio si no existe
echo Creando directorio C:\Backups...
if not exist "C:\Backups" (
    mkdir "C:\Backups"
    echo Directorio creado.
) else (
    echo Directorio ya existe.
)
echo.

REM Dar permisos a SQL Server
echo Otorgando permisos a NT Service\MSSQL$SQLEXPRESS...
icacls "C:\Backups" /grant "NT Service\MSSQL$SQLEXPRESS:(OI)(CI)F"
echo.

REM Verificar permisos
echo Verificando permisos actuales:
icacls "C:\Backups" | findstr "MSSQL"
echo.

echo ========================================
echo Proceso completado
echo ========================================
echo.
echo Ahora puedes volver a intentar el backup desde la aplicacion web.
echo.
pause
