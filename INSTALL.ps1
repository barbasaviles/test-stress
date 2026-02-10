# ========================================================================
# SCRIPT DE INSTALACIÓN AUTOMÁTICA - PRUEBAS DE CARGA CON ARTILLERY
# ========================================================================
# Este script instala todas las dependencias necesarias para ejecutar
# pruebas de carga con Artillery en Windows
# ========================================================================

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "  INSTALACIÓN DE HERRAMIENTAS PARA PRUEBAS DE CARGA" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si se está ejecutando como Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[ADVERTENCIA] Este script requiere privilegios de administrador para algunas operaciones." -ForegroundColor Yellow
    Write-Host "Se recomienda ejecutar PowerShell como Administrador para una instalación completa." -ForegroundColor Yellow
    Write-Host ""
    $continuar = Read-Host "¿Desea continuar de todos modos? (S/N)"
    if ($continuar -ne "S" -and $continuar -ne "s") {
        Write-Host "Instalación cancelada." -ForegroundColor Red
        exit
    }
}

# ========================================================================
# PASO 1: Verificar e Instalar Node.js
# ========================================================================
Write-Host "[PASO 1/5] Verificando Node.js..." -ForegroundColor Green

try {
    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        Write-Host "  ✓ Node.js ya está instalado: $nodeVersion" -ForegroundColor Green
    } else {
        throw "Node.js no encontrado"
    }
} catch {
    Write-Host "  ✗ Node.js no está instalado" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Descargando Node.js LTS..." -ForegroundColor Yellow
    
    # Descargar instalador de Node.js
    $nodeUrl = "https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi"
    $nodeInstaller = "$env:TEMP\node-installer.msi"
    
    try {
        Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeInstaller
        Write-Host "  Instalando Node.js (esto puede tomar unos minutos)..." -ForegroundColor Yellow
        Start-Process msiexec.exe -Wait -ArgumentList "/i $nodeInstaller /quiet /norestart"
        
        # Refrescar variables de entorno
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-Host "  ✓ Node.js instalado correctamente" -ForegroundColor Green
        Remove-Item $nodeInstaller -ErrorAction SilentlyContinue
    } catch {
        Write-Host "  ✗ Error al instalar Node.js automáticamente" -ForegroundColor Red
        Write-Host "  Por favor, descargue e instale Node.js manualmente desde: https://nodejs.org/" -ForegroundColor Yellow
        exit 1
    }
}

# ========================================================================
# PASO 2: Verificar npm
# ========================================================================
Write-Host ""
Write-Host "[PASO 2/5] Verificando npm..." -ForegroundColor Green

try {
    $npmVersion = npm --version 2>$null
    if ($npmVersion) {
        Write-Host "  ✓ npm está instalado: v$npmVersion" -ForegroundColor Green
    } else {
        throw "npm no encontrado"
    }
} catch {
    Write-Host "  ✗ npm no está instalado correctamente" -ForegroundColor Red
    Write-Host "  Reinstale Node.js desde: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# ========================================================================
# PASO 3: Instalar Artillery globalmente
# ========================================================================
Write-Host ""
Write-Host "[PASO 3/5] Instalando Artillery..." -ForegroundColor Green

try {
    # Verificar si Artillery ya está instalado
    $artilleryVersion = artillery --version 2>$null
    if ($artilleryVersion) {
        Write-Host "  ✓ Artillery ya está instalado: $artilleryVersion" -ForegroundColor Green
        $actualizar = Read-Host "  ¿Desea actualizarlo a la última versión? (S/N)"
        if ($actualizar -eq "S" -or $actualizar -eq "s") {
            npm install -g artillery@latest
            Write-Host "  ✓ Artillery actualizado" -ForegroundColor Green
        }
    } else {
        Write-Host "  Instalando Artillery (esto puede tomar varios minutos)..." -ForegroundColor Yellow
        npm install -g artillery@latest
        Write-Host "  ✓ Artillery instalado correctamente" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Error al instalar Artillery" -ForegroundColor Red
    Write-Host "  Intente instalarlo manualmente: npm install -g artillery" -ForegroundColor Yellow
    exit 1
}

# ========================================================================
# PASO 4: Instalar dependencias del proyecto
# ========================================================================
Write-Host ""
Write-Host "[PASO 4/5] Instalando dependencias del proyecto..." -ForegroundColor Green

if (Test-Path "package.json") {
    try {
        npm install
        Write-Host "  ✓ Dependencias del proyecto instaladas" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Error al instalar dependencias del proyecto" -ForegroundColor Red
        Write-Host "  Intente ejecutar manualmente: npm install" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ! No se encontró package.json en el directorio actual" -ForegroundColor Yellow
    Write-Host "  Asegúrese de estar en el directorio del proyecto" -ForegroundColor Yellow
}

# ========================================================================
# PASO 5: Verificar archivo .env
# ========================================================================
Write-Host ""
Write-Host "[PASO 5/5] Verificando configuración..." -ForegroundColor Green

if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "  ✓ Archivo .env creado desde .env.example" -ForegroundColor Green
        Write-Host "  ⚠ IMPORTANTE: Edite el archivo .env con sus configuraciones" -ForegroundColor Yellow
    } else {
        Write-Host "  ! No se encontró archivo .env ni .env.example" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✓ Archivo .env ya existe" -ForegroundColor Green
}

# ========================================================================
# RESUMEN DE INSTALACIÓN
# ========================================================================
Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "  INSTALACIÓN COMPLETADA" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Herramientas instaladas:" -ForegroundColor White
Write-Host "  ✓ Node.js: $(node --version)" -ForegroundColor Green
Write-Host "  ✓ npm: v$(npm --version)" -ForegroundColor Green
Write-Host "  ✓ Artillery: $(artillery --version)" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor White
Write-Host "  1. Edite el archivo .env con sus configuraciones" -ForegroundColor Yellow
Write-Host "  2. Capture la cookie de autenticación (vea GUIA_COMPLETA.md)" -ForegroundColor Yellow
Write-Host "  3. Ejecute pruebas con: .\EJECUTAR.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "Para más información, consulte: GUIA_COMPLETA.md" -ForegroundColor Cyan
Write-Host ""
