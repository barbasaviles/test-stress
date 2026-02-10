# ========================================================================
# SCRIPT DE EJECUCIÓN - PRUEBAS DE CARGA CON ARTILLERY
# ========================================================================
# Este script facilita la ejecución de diferentes tipos de pruebas
# ========================================================================

param(
    [Parameter(Position=0)]
    [ValidateSet("smoke", "stress", "production", "custom")]
    [string]$TipoPrueba = "",
    
    [Parameter()]
    [string]$Archivo = "",
    
    [Parameter()]
    [switch]$Local,
    
    [Parameter()]
    [switch]$Cloud,
    
    [Parameter()]
    [switch]$ConReporte,
    
    [Parameter()]
    [switch]$Help
)

function Show-Help {
    Write-Host ""
    Write-Host "========================================================================" -ForegroundColor Cyan
    Write-Host "  SCRIPT DE EJECUCIÓN - PRUEBAS DE CARGA" -ForegroundColor Cyan
    Write-Host "========================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USO:" -ForegroundColor White
    Write-Host "  .\EJECUTAR.ps1 [TIPO_PRUEBA] [OPCIONES]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "TIPOS DE PRUEBA:" -ForegroundColor White
    Write-Host "  smoke       - Prueba de humo (10s, 1 usuario/seg)" -ForegroundColor Green
    Write-Host "  stress      - Prueba de estrés (300s, 1-20 usuarios/seg)" -ForegroundColor Green
    Write-Host "  production  - Prueba de producción (480s, 2-50 usuarios/seg)" -ForegroundColor Green
    Write-Host "  custom      - Prueba personalizada (requiere -Archivo)" -ForegroundColor Green
    Write-Host ""
    Write-Host "OPCIONES:" -ForegroundColor White
    Write-Host "  -Archivo <ruta>  - Especificar archivo de configuración" -ForegroundColor Yellow
    Write-Host "  -Local           - Ejecutar en modo local (predeterminado)" -ForegroundColor Yellow
    Write-Host "  -Cloud           - Ejecutar en Artillery Cloud" -ForegroundColor Yellow
    Write-Host "  -ConReporte      - Generar reporte HTML después de la prueba" -ForegroundColor Yellow
    Write-Host "  -Help            - Mostrar esta ayuda" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "EJEMPLOS:" -ForegroundColor White
    Write-Host "  .\EJECUTAR.ps1 smoke" -ForegroundColor Cyan
    Write-Host "  .\EJECUTAR.ps1 stress -ConReporte" -ForegroundColor Cyan
    Write-Host "  .\EJECUTAR.ps1 production -Cloud" -ForegroundColor Cyan
    Write-Host "  .\EJECUTAR.ps1 custom -Archivo artillery-custom.yml -ConReporte" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Para más información, consulte: GUIA_COMPLETA.md" -ForegroundColor White
    Write-Host ""
}

# Mostrar ayuda si se solicita
if ($Help) {
    Show-Help
    exit 0
}

# Si no se especifica tipo de prueba, mostrar menú interactivo
if ($TipoPrueba -eq "") {
    Write-Host ""
    Write-Host "========================================================================" -ForegroundColor Cyan
    Write-Host "  MENÚ DE PRUEBAS DE CARGA" -ForegroundColor Cyan
    Write-Host "========================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Seleccione el tipo de prueba:" -ForegroundColor White
    Write-Host ""
    Write-Host "  [1] Smoke Test (Prueba de humo)" -ForegroundColor Green
    Write-Host "      - Duración: 10 segundos" -ForegroundColor Gray
    Write-Host "      - Carga: 1 usuario por segundo" -ForegroundColor Gray
    Write-Host "      - Propósito: Verificar que el sistema responde" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [2] Stress Test (Prueba de estrés)" -ForegroundColor Yellow
    Write-Host "      - Duración: 5 minutos" -ForegroundColor Gray
    Write-Host "      - Carga: 1-20 usuarios por segundo (incremental)" -ForegroundColor Gray
    Write-Host "      - Propósito: Encontrar límites del sistema" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [3] Production Test (Prueba de producción)" -ForegroundColor Red
    Write-Host "      - Duración: 8 minutos" -ForegroundColor Gray
    Write-Host "      - Carga: 2-50 usuarios por segundo" -ForegroundColor Gray
    Write-Host "      - Propósito: Simular carga real de producción" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [4] Prueba personalizada" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [0] Salir" -ForegroundColor White
    Write-Host ""
    
    $opcion = Read-Host "Ingrese su opción (0-4)"
    
    switch ($opcion) {
        "1" { $TipoPrueba = "smoke" }
        "2" { $TipoPrueba = "stress" }
        "3" { $TipoPrueba = "production" }
        "4" { 
            $TipoPrueba = "custom"
            $Archivo = Read-Host "Ingrese la ruta del archivo de configuración"
        }
        "0" {
            Write-Host "Saliendo..." -ForegroundColor Yellow
            exit 0
        }
        default {
            Write-Host "Opción inválida" -ForegroundColor Red
            exit 1
        }
    }
    
    # Preguntar modo de ejecución
    Write-Host ""
    $modoEjecucion = Read-Host "¿Ejecutar en Artillery Cloud? (S/N)"
    if ($modoEjecucion -eq "S" -or $modoEjecucion -eq "s") {
        $Cloud = $true
    } else {
        $Local = $true
    }
    
    # Preguntar por reporte
    Write-Host ""
    $generarReporte = Read-Host "¿Generar reporte HTML? (S/N)"
    if ($generarReporte -eq "S" -or $generarReporte -eq "s") {
        $ConReporte = $true
    }
}

# Determinar archivo de configuración
if ($TipoPrueba -eq "custom") {
    if ($Archivo -eq "") {
        Write-Host "Error: Debe especificar un archivo con -Archivo para pruebas personalizadas" -ForegroundColor Red
        exit 1
    }
    $archivoConfig = $Archivo
} else {
    $archivoConfig = "artillery-admin.yml"
}

# Verificar que el archivo existe
if (-not (Test-Path $archivoConfig)) {
    Write-Host "Error: No se encontró el archivo de configuración: $archivoConfig" -ForegroundColor Red
    exit 1
}

# Verificar archivo .env
if (-not (Test-Path ".env")) {
    Write-Host "Error: No se encontró el archivo .env" -ForegroundColor Red
    Write-Host "Ejecute primero: .\INSTALL.ps1" -ForegroundColor Yellow
    exit 1
}

# Cargar variables de entorno
Get-Content .env | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]*?)\s*=\s*(.+?)\s*$') {
        $name = $matches[1]
        $value = $matches[2] -replace '^"(.*)"$', '$1'
        [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

# Preparar comando
Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "  INICIANDO PRUEBA DE CARGA" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuración:" -ForegroundColor White
Write-Host "  Tipo de prueba: $TipoPrueba" -ForegroundColor Yellow
Write-Host "  Archivo: $archivoConfig" -ForegroundColor Yellow
Write-Host "  Modo: $(if ($Cloud) { 'Artillery Cloud' } else { 'Local' })" -ForegroundColor Yellow
Write-Host "  Reporte HTML: $(if ($ConReporte) { 'Sí' } else { 'No' })" -ForegroundColor Yellow
Write-Host ""

# Nombre del archivo de salida
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputJson = "report_${TipoPrueba}_${timestamp}.json"
$outputHtml = "report_${TipoPrueba}_${timestamp}.html"

# Construir comando
if ($Cloud) {
    # Ejecución en Artillery Cloud
    Write-Host "Ejecutando en Artillery Cloud..." -ForegroundColor Green
    Write-Host ""
    
    if ($TipoPrueba -ne "custom") {
        artillery run --environment $TipoPrueba --output $outputJson $archivoConfig
    } else {
        artillery run --output $outputJson $archivoConfig
    }
    
} else {
    # Ejecución local
    Write-Host "Ejecutando localmente..." -ForegroundColor Green
    Write-Host ""
    
    if ($TipoPrueba -ne "custom") {
        artillery run --environment $TipoPrueba --output $outputJson $archivoConfig
    } else {
        artillery run --output $outputJson $archivoConfig
    }
}

# Verificar resultado
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================================================" -ForegroundColor Green
    Write-Host "  PRUEBA COMPLETADA EXITOSAMENTE" -ForegroundColor Green
    Write-Host "========================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Resultados guardados en: $outputJson" -ForegroundColor Yellow
    Write-Host ""
    
    # Generar reporte HTML si se solicitó
    if ($ConReporte -and (Test-Path "generate-report.js")) {
        Write-Host "Generando reporte HTML..." -ForegroundColor Cyan
        node generate-report.js $outputJson $outputHtml
        
        if (Test-Path $outputHtml) {
            Write-Host "  ✓ Reporte HTML generado: $outputHtml" -ForegroundColor Green
            
            # Preguntar si desea abrir el reporte
            $abrirReporte = Read-Host "¿Desea abrir el reporte en el navegador? (S/N)"
            if ($abrirReporte -eq "S" -or $abrirReporte -eq "s") {
                Start-Process $outputHtml
            }
        } else {
            Write-Host "  ✗ Error al generar reporte HTML" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Para ver un resumen rápido:" -ForegroundColor White
    Write-Host "  artillery report $outputJson" -ForegroundColor Cyan
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "========================================================================" -ForegroundColor Red
    Write-Host "  ERROR EN LA PRUEBA" -ForegroundColor Red
    Write-Host "========================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "La prueba finalizó con errores. Revise los logs anteriores." -ForegroundColor Yellow
    Write-Host ""
}
