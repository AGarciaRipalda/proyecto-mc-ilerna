@echo off
echo ========================================
echo Ejecutando script2.sql (CREATE DATABASE y TABLES)
echo ========================================
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "source script2.sql"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No se pudo ejecutar script2.sql
    pause
    exit /b 1
)

echo.
echo ========================================
echo Ejecutando insert2.sql (INSERT DATA)
echo ========================================
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "source insert2.sql"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No se pudo ejecutar insert2.sql
    pause
    exit /b 1
)

echo.
echo ========================================
echo Scripts ejecutados correctamente!
echo ========================================
echo.
echo Verificando datos insertados...
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "USE mc_ilerna; SELECT COUNT(*) AS total_lineas_pedido FROM lineas_pedido;"

pause
