# 🚀 GUÍA COMPLETA: PRUEBAS DE CARGA CON ARTILLERY EN WINDOWS

Esta guía te ayudará a configurar y ejecutar pruebas de carga en Windows desde cero.

---

## 📋 ÍNDICE

1. [Instalación Rápida](#1-instalación-rápida)
2. [Captura de Cookie de Autenticación](#2-captura-de-cookie-de-autenticación)
3. [Configuración del Proyecto](#3-configuración-del-proyecto)
4. [Tipos de Pruebas Disponibles](#4-tipos-de-pruebas-disponibles)
5. [Ejecución de Pruebas](#5-ejecución-de-pruebas)
6. [Interpretación de Resultados](#6-interpretación-de-resultados)
7. [Solución de Problemas](#7-solución-de-problemas)

---

## 1. INSTALACIÓN RÁPIDA

### Opción A: Instalación Automatizada (Recomendada)

Abre PowerShell como **Administrador** y ejecuta:

```powershell
cd c:\Users\Gabriel\.gemini\antigravity\scratch\prueba_carga
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\INSTALL.ps1
```

Este script instalará automáticamente:
- ✅ Node.js (si no está instalado)
- ✅ npm (incluido con Node.js)
- ✅ Artillery (herramienta de pruebas de carga)
- ✅ Dependencias del proyecto

### Opción B: Instalación Manual

Si prefieres instalar manualmente:

#### Paso 1: Instalar Node.js

1. Descarga Node.js LTS desde: https://nodejs.org/
2. Ejecuta el instalador
3. Verifica la instalación:

```powershell
node --version
npm --version
```

#### Paso 2: Instalar Artillery

```powershell
npm install -g artillery
```

#### Paso 3: Instalar dependencias del proyecto

```powershell
cd c:\Users\Gabriel\.gemini\antigravity\scratch\prueba_carga
npm install
```

---

## 2. CAPTURA DE COOKIE DE AUTENTICACIÓN

Las pruebas necesitan autenticación para acceder a las páginas protegidas. Aquí te explico **3 métodos** para capturar la cookie.

### 🔹 Método 1: Usando DevTools de Chrome (Recomendado)

1. **Abre tu aplicación web** en Chrome
2. **Inicia sesión** normalmente
3. **Presiona F12** para abrir las DevTools
4. Ve a la pestaña **"Application"** (o "Aplicación")
5. En el menú izquierdo, expande **"Cookies"**
6. Selecciona tu dominio (ej: `escalamientosnaturaha.grupokonecta.local`)
7. Busca la cookie **PHPSESSID** (o la cookie de sesión que use tu aplicación)
8. **Copia el valor** de la cookie

![Captura de Cookie en Chrome DevTools](https://via.placeholder.com/800x400?text=Chrome+DevTools+Cookie+Capture)

9. Edita el archivo `.env` y actualiza:

```env
AUTH_COOKIE="PHPSESSID=TU_VALOR_DE_COOKIE_AQUI"
```

### 🔹 Método 2: Script PowerShell Automático

Ejecuta este script para listar todas las cookies de Chrome:

```powershell
.\CAPTURAR_COOKIE.ps1
```

El script mostrará todas las cookies disponibles y te permite copiar la que necesitas.

### 🔹 Método 3: Usando la consola del navegador

1. Abre tu aplicación web y **inicia sesión**
2. **Presiona F12** y ve a la pestaña **"Console"**
3. Ejecuta este comando:

```javascript
document.cookie.split(';').forEach(c => console.log(c.trim()))
```

4. Busca la línea que contiene `PHPSESSID=...`
5. Copia el valor completo

---

## 3. CONFIGURACIÓN DEL PROYECTO

### Archivo `.env`

Asegúrate de tener un archivo `.env` con esta configuración:

```env
# URL del servidor a probar
TARGET_URL=https://escalamientosnaturaha.grupokonecta.local

# Cookie de autenticación (capturada del navegador)
AUTH_COOKIE="PHPSESSID=7d6ok7rq9er6v6tfbgvnsb87ne"

# User-Agent (simula un navegador Chrome en Windows)
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36"

# Artillery Cloud API Key (opcional, solo si usas Artillery Cloud)
ARTILLERY_CLOUD_API_KEY=tu_api_key_aqui
```

### Variables importantes:

- **TARGET_URL**: La URL base de tu aplicación
- **AUTH_COOKIE**: Cookie de sesión capturada del navegador
- **USER_AGENT**: Identifica el navegador (déjalo como está)
- **ARTILLERY_CLOUD_API_KEY**: Solo necesario si ejecutas en Artillery Cloud

---

## 4. TIPOS DE PRUEBAS DISPONIBLES

### 🟢 Smoke Test (Prueba de Humo)

**Propósito**: Verificar que el sistema responde correctamente

```yaml
Duración: 10 segundos
Usuarios: 1 por segundo
Total VUs: ~10 usuarios virtuales
```

**Cuándo usar**: 
- Después de cada despliegue
- Para validación rápida
- Antes de pruebas más intensivas

### 🟡 Stress Test (Prueba de Estrés)

**Propósito**: Encontrar los límites del sistema

```yaml
Fase 1 (60s): 1 → 5 usuarios/seg
Fase 2 (120s): 5 → 15 usuarios/seg  
Fase 3 (120s): 15 → 20 usuarios/seg
Total: 5 minutos
```

**Cuándo usar**:
- Para encontrar el punto de quiebre
- Validar escalabilidad
- Planificación de capacidad

### 🔴 Production Test (Prueba de Producción)

**Propósito**: Simular carga real de producción

```yaml
Calentamiento (60s): 2 → 10 usuarios/seg
Rampa (120s): 10 → 50 usuarios/seg
Sostenida (300s): 50 usuarios/seg constante
Total: 8 minutos
```

**Cuándo usar**:
- Antes de lanzamientos importantes
- Validación de rendimiento en producción
- Pruebas de resistencia

---

## 5. EJECUCIÓN DE PRUEBAS

### 🚀 Método 1: Script Interactivo (Más Fácil)

```powershell
.\EJECUTAR.ps1
```

Te mostrará un menú interactivo:

```
========================================================================
  MENÚ DE PRUEBAS DE CARGA
========================================================================

Seleccione el tipo de prueba:

  [1] Smoke Test (Prueba de humo)
  [2] Stress Test (Prueba de estrés)
  [3] Production Test (Prueba de producción)
  [4] Prueba personalizada
  [0] Salir

Ingrese su opción (0-4):
```

### 🚀 Método 2: Comandos Directos

#### Smoke Test

```powershell
.\EJECUTAR.ps1 smoke -ConReporte
```

#### Stress Test

```powershell
.\EJECUTAR.ps1 stress -ConReporte
```

#### Production Test

```powershell
.\EJECUTAR.ps1 production -ConReporte
```

#### Con Artillery Cloud

```powershell
.\EJECUTAR.ps1 smoke -Cloud -ConReporte
```

### 🚀 Método 3: Comandos Artillery Directos

Si prefieres usar Artillery directamente:

```powershell
# Smoke Test
artillery run --environment smoke --output report_smoke.json artillery-admin.yml

# Stress Test
artillery run --environment stress --output report_stress.json artillery-admin.yml

# Production Test
artillery run --environment production --output report_production.json artillery-admin.yml
```

### Generar Reporte HTML

```powershell
node generate-report.js report_smoke.json report_smoke.html
```

---

## 6. INTERPRETACIÓN DE RESULTADOS

### Métricas Clave

Cuando ejecutes una prueba, verás estas métricas:

```
Summary report @ 14:23:45(-0500)
──────────────────────────────────────────────────────────

http.codes.200: ................................................................ 1250
http.request_rate: ............................................................. 12/sec
http.requests: ................................................................. 1250
http.response_time:
  min: ......................................................................... 45
  max: ......................................................................... 2340
  median: ...................................................................... 156.3
  p95: ......................................................................... 567.8
  p99: ......................................................................... 890.2
http.responses: ................................................................ 1250
vusers.completed: .............................................................. 125
vusers.created: ................................................................ 125
vusers.created_by_name.Navegación Admin (Capacidad Real): ..................... 125
vusers.failed: ................................................................. 0
vusers.session_length:
  min: ......................................................................... 12340
  max: ......................................................................... 23450
  median: ...................................................................... 18234.5
  p95: ......................................................................... 21234.7
  p99: ......................................................................... 22456.3
```

#### 📊 Qué Significa Cada Métrica

| Métrica | Significado | Valor Ideal |
|---------|-------------|-------------|
| `http.codes.200` | Respuestas exitosas | 100% de las requests |
| `http.request_rate` | Requests por segundo | Según tu objetivo |
| `http.response_time.median` | Tiempo de respuesta típico | < 500ms |
| `http.response_time.p95` | 95% responden en este tiempo | < 1000ms |
| `http.response_time.p99` | 99% responden en este tiempo | < 2000ms |
| `vusers.failed` | Usuarios que fallaron | 0 |

### 🟢 Resultados Buenos

```
✓ Código 200: 100% de las respuestas
✓ Response time median: < 500ms
✓ P95: < 1000ms
✓ Usuarios fallidos: 0
```

### 🟡 Resultados Aceptables

```
⚠ Código 200: > 95% de las respuestas
⚠ Response time median: 500-1000ms
⚠ P95: 1000-2000ms
⚠ Usuarios fallidos: < 1%
```

### 🔴 Resultados Problemáticos

```
✗ Código 200: < 95%
✗ Errores 5xx presentes
✗ Response time median: > 1000ms
✗ P95: > 2000ms
✗ Usuarios fallidos: > 1%
```

---

## 7. SOLUCIÓN DE PROBLEMAS

### ❌ Error: "artillery: command not found"

**Causa**: Artillery no está instalado globalmente

**Solución**:
```powershell
npm install -g artillery
```

### ❌ Error: "Cannot find module"

**Causa**: Dependencias del proyecto no instaladas

**Solución**:
```powershell
npm install
```

### ❌ Error: 401 Unauthorized / 403 Forbidden

**Causa**: Cookie de autenticación inválida o expirada

**Solución**:
1. Captura una nueva cookie del navegador
2. Actualiza el archivo `.env`
3. Asegúrate de que la cookie sea válida

### ❌ Error: "ECONNREFUSED" o "ETIMEDOUT"

**Causa**: No se puede conectar al servidor

**Solución**:
1. Verifica que `TARGET_URL` en `.env` sea correcta
2. Verifica que el servidor esté en funcionamiento
3. Verifica conectividad de red

### ❌ Error: SSL Certificate

**Causa**: Certificado SSL autofirmado o inválido

**Solución**: El archivo de configuración ya incluye:
```yaml
tls:
  rejectUnauthorized: false
```

### ❌ Métricas muy lentas

**Posibles causas**:
- Servidor sobrecargado
- Cookie expirada (servidor requiere re-autenticación)
- Red lenta
- Configuración de carga muy agresiva

**Solución**:
1. Verifica la cookie
2. Reduce la carga (usa smoke test primero)
3. Verifica recursos del servidor

---

## 📚 REFERENCIA RÁPIDA

### Comandos Esenciales

```powershell
# Instalar dependencias
.\INSTALL.ps1

# Ejecutar prueba interactiva
.\EJECUTAR.ps1

# Ejecutar prueba específica
.\EJECUTAR.ps1 smoke -ConReporte

# Ver reporte de resultados
artillery report report_smoke.json

# Generar HTML
node generate-report.js report_smoke.json report_smoke.html
```

### Archivos Importantes

| Archivo | Descripción |
|---------|-------------|
| `INSTALL.ps1` | Script de instalación automatizada |
| `EJECUTAR.ps1` | Script de ejecución de pruebas |
| `CAPTURAR_COOKIE.ps1` | Script para capturar cookies |
| `.env` | Configuración (URL, cookie, etc.) |
| `artillery-admin.yml` | Configuración de pruebas |
| `processor.js` | Lógica personalizada de Artillery |
| `generate-report.js` | Generador de reportes HTML |

---

## 🎯 FLUJO DE TRABAJO RECOMENDADO

### Primera Vez

1. ✅ Ejecutar `INSTALL.ps1`
2. ✅ Capturar cookie de autenticación
3. ✅ Editar archivo `.env`
4. ✅ Ejecutar smoke test: `.\EJECUTAR.ps1 smoke`
5. ✅ Verificar que todo funciona correctamente

### Rutina Normal

1. ✅ Verificar/actualizar cookie (si expiró)
2. ✅ Ejecutar prueba: `.\EJECUTAR.ps1`
3. ✅ Revisar resultados
4. ✅ Generar y analizar reporte HTML

### Antes de Despliegue a Producción

1. ✅ Ejecutar smoke test
2. ✅ Ejecutar stress test
3. ✅ Ejecutar production test
4. ✅ Verificar que todas las métricas están en verde
5. ✅ Documentar resultados

---

## 🆘 SOPORTE ADICIONAL

### Recursos Oficiales

- **Artillery Docs**: https://artillery.io/docs
- **Node.js Docs**: https://nodejs.org/docs
- **Artillery Cloud**: https://app.artillery.io

### Información de Depuración

Si necesitas ayuda, recopila esta información:

```powershell
# Versiones instaladas
node --version
npm --version
artillery --version

# Contenido de .env (SIN la cookie real)
Get-Content .env | Select-String -Pattern "TARGET_URL|USER_AGENT"

# Últimos logs de error
Get-Content responses.log -Tail 50
```

---

## 📝 NOTAS FINALES

### Mejores Prácticas

- ✅ Actualiza la cookie antes de cada sesión de pruebas
- ✅ Comienza siempre con smoke test
- ✅ Ejecuta pruebas en horarios de baja carga
- ✅ Documenta tus resultados
- ✅ Compara resultados entre versiones

### Advertencias

- ⚠️ Las pruebas de producción generan **carga real** en el servidor
- ⚠️ Coordina con tu equipo antes de ejecutar pruebas intensivas
- ⚠️ No ejecutes pruebas de estrés en producción sin autorización
- ⚠️ Las cookies expiran, actualízalas regularmente

---

**¡Listo para comenzar!** 🚀

Ejecuta `.\INSTALL.ps1` para comenzar.
