# ========================================================================
# SCRIPT DE CAPTURA DE COOKIE - PRUEBAS DE CARGA
# ========================================================================
# Este script ayuda a extraer cookies del navegador Chrome para pruebas
# ========================================================================

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "  CAPTURA DE COOKIE DE AUTENTICACIÓN" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

# ========================================================================
# MÉTODO 1: Instrucciones manuales (más confiable)
# ========================================================================

Write-Host "MÉTODO RECOMENDADO: Captura Manual desde Chrome DevTools" -ForegroundColor Green
Write-Host ""
Write-Host "Sigue estos pasos:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Abre Chrome y navega a tu aplicación" -ForegroundColor Yellow
Write-Host "  2. Inicia sesión normalmente" -ForegroundColor Yellow
Write-Host "  3. Presiona F12 para abrir DevTools" -ForegroundColor Yellow
Write-Host "  4. Ve a la pestaña 'Application' (o 'Aplicación')" -ForegroundColor Yellow
Write-Host "  5. En el menú izquierdo, expande 'Cookies'" -ForegroundColor Yellow
Write-Host "  6. Selecciona tu dominio" -ForegroundColor Yellow
Write-Host "  7. Busca la cookie 'PHPSESSID' (o la cookie de sesión)" -ForegroundColor Yellow
Write-Host "  8. Copia el VALOR de la cookie" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Ejemplo del valor: 7d6ok7rq9er6v6tfbgvnsb87ne" -ForegroundColor Cyan
Write-Host ""

$continuar = Read-Host "¿Ya tienes el valor de la cookie? (S/N)"

if ($continuar -eq "S" -or $continuar -eq "s") {
    Write-Host ""
    $cookieValue = Read-Host "Pega el valor de la cookie aquí"
    
    if ($cookieValue -ne "") {
        # Actualizar archivo .env
        if (Test-Path ".env") {
            $envContent = Get-Content ".env"
            $envContent = $envContent -replace 'AUTH_COOKIE="[^"]*"', "AUTH_COOKIE=`"PHPSESSID=$cookieValue`""
            $envContent | Set-Content ".env"
            
            Write-Host ""
            Write-Host "  ✓ Cookie actualizada en .env" -ForegroundColor Green
            Write-Host ""
            Write-Host "Valor configurado:" -ForegroundColor White
            Write-Host "  AUTH_COOKIE=`"PHPSESSID=$cookieValue`"" -ForegroundColor Cyan
            Write-Host ""
        }
        else {
            Write-Host ""
            Write-Host "  ✗ No se encontró el archivo .env" -ForegroundColor Red
            Write-Host "  Ejecute primero: .\INSTALL.ps1" -ForegroundColor Yellow
            Write-Host ""
        }
    }
    else {
        Write-Host ""
        Write-Host "  ✗ No se ingresó ningún valor" -ForegroundColor Red
        Write-Host ""
    }
    
    exit 0
}

# ========================================================================
# MÉTODO 2: Usando JavaScript en la consola del navegador
# ========================================================================

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "MÉTODO ALTERNATIVO: Usando la Consola del Navegador" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Sigue estos pasos:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Abre Chrome y navega a tu aplicación" -ForegroundColor Yellow
Write-Host "  2. Inicia sesión normalmente" -ForegroundColor Yellow
Write-Host "  3. Presiona F12 para abrir DevTools" -ForegroundColor Yellow
Write-Host "  4. Ve a la pestaña 'Console' (o 'Consola')" -ForegroundColor Yellow
Write-Host "  5. Copia y pega este comando:" -ForegroundColor Yellow
Write-Host ""
Write-Host "     document.cookie.split(';').forEach(c => console.log(c.trim()))" -ForegroundColor Cyan
Write-Host ""
Write-Host "  6. Presiona ENTER" -ForegroundColor Yellow
Write-Host "  7. Busca la línea que dice 'PHPSESSID=...'" -ForegroundColor Yellow
Write-Host "  8. Copia solo el valor después del '='" -ForegroundColor Yellow
Write-Host ""

# ========================================================================
# MÉTODO 3: Información sobre cookies de Chrome (requiere más pasos)
# ========================================================================

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "INFORMACIÓN ADICIONAL" -ForegroundColor White
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ubicación del archivo de cookies de Chrome:" -ForegroundColor White
Write-Host "  $env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies" -ForegroundColor Yellow
Write-Host ""
Write-Host "NOTA: Este archivo está encriptado y requiere herramientas especiales" -ForegroundColor Red
Write-Host "para leerlo. Se recomienda usar el método manual explicado arriba." -ForegroundColor Red
Write-Host ""

# ========================================================================
# MÉTODO 4: Generar script de navegador
# ========================================================================

Write-Host ""
$generarScript = Read-Host "¿Desea generar un snippet de JavaScript para copiar al navegador? (S/N)"

if ($generarScript -eq "S" -or $generarScript -eq "s") {
    $scriptJS = @"
// ========================================================================
// Script para extraer cookies en el navegador
// ========================================================================
// Instrucciones:
// 1. Abre tu aplicación web y inicia sesión
// 2. Abre DevTools (F12)
// 3. Ve a la pestaña Console
// 4. Copia y pega este código completo
// 5. Presiona ENTER
// ========================================================================

console.log('%c=== COOKIES DEL NAVEGADOR ===', 'color: cyan; font-size: 16px; font-weight: bold');
console.log('');

// Obtener todas las cookies
const cookies = document.cookie.split(';');

// Buscar específicamente PHPSESSID
let phpsessid = null;

cookies.forEach(cookie => {
    const [name, value] = cookie.trim().split('=');
    console.log(`%c${name}`, 'color: yellow', '=', value);
    
    if (name === 'PHPSESSID') {
        phpsessid = value;
    }
});

console.log('');

if (phpsessid) {
    console.log('%c✓ Cookie PHPSESSID encontrada:', 'color: green; font-weight: bold');
    console.log('%c' + phpsessid, 'color: cyan; font-size: 14px');
    console.log('');
    console.log('%cCopia este valor y úsalo en tu archivo .env:', 'color: white');
    console.log(`%cAUTH_COOKIE="PHPSESSID=${phpsessid}"`, 'color: yellow; background: #333; padding: 10px');
    
    // Intentar copiar al portapapeles
    navigator.clipboard.writeText(phpsessid).then(() => {
        console.log('%c✓ ¡Valor copiado al portapapeles!', 'color: green; font-weight: bold');
    }).catch(() => {
        console.log('%c⚠ No se pudo copiar automáticamente. Copia el valor manualmente.', 'color: orange');
    });
} else {
    console.log('%c✗ No se encontró cookie PHPSESSID', 'color: red; font-weight: bold');
    console.log('%c¿Estás seguro de haber iniciado sesión?', 'color: orange');
}

console.log('');
"@
    
    # Guardar en archivo
    $scriptFile = "extraer-cookie.js"
    $scriptJS | Set-Content $scriptFile
    
    Write-Host ""
    Write-Host "  ✓ Script generado: $scriptFile" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ahora:" -ForegroundColor White
    Write-Host "  1. Abre el archivo $scriptFile" -ForegroundColor Yellow
    Write-Host "  2. Copia TODO el contenido" -ForegroundColor Yellow
    Write-Host "  3. Abre Chrome DevTools (F12)" -ForegroundColor Yellow
    Write-Host "  4. Ve a la pestaña 'Console'" -ForegroundColor Yellow
    Write-Host "  5. Pega el código y presiona ENTER" -ForegroundColor Yellow
    Write-Host "  6. Copia el valor de PHPSESSID que se muestra" -ForegroundColor Yellow
    Write-Host ""
    
    # Abrir archivo
    $abrirArchivo = Read-Host "¿Desea abrir el archivo ahora? (S/N)"
    if ($abrirArchivo -eq "S" -or $abrirArchivo -eq "s") {
        notepad $scriptFile
    }
}

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "RESUMEN" -ForegroundColor White
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Una vez que tengas el valor de la cookie:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Abre el archivo .env" -ForegroundColor Yellow
Write-Host "  2. Busca la línea AUTH_COOKIE" -ForegroundColor Yellow
Write-Host "  3. Reemplaza el valor con tu cookie:" -ForegroundColor Yellow
Write-Host '     AUTH_COOKIE="PHPSESSID=TU_VALOR_AQUI"' -ForegroundColor Cyan
Write-Host "  4. Guarda el archivo" -ForegroundColor Yellow
Write-Host ""
Write-Host "Luego ejecuta las pruebas con:" -ForegroundColor White
Write-Host "  .\EJECUTAR.ps1" -ForegroundColor Cyan
Write-Host ""
