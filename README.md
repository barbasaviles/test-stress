# 🚀 Sistema de Pruebas de Carga con Artillery

Sistema completo para ejecutar pruebas de carga en Windows con Artillery, incluyendo instalación automatizada, captura de cookies y diferentes tipos de pruebas.

## 📁 Archivos del Sistema

| Archivo | Descripción |
|---------|-------------|
| **[GUIA_COMPLETA.md](GUIA_COMPLETA.md)** | 📖 Guía completa paso a paso (LÉEME PRIMERO) |
| **[REFERENCIA_RAPIDA.md](REFERENCIA_RAPIDA.md)** | ⚡ Referencia rápida de comandos |
| **[INSTALL.ps1](INSTALL.ps1)** | 🔧 Script de instalación automatizada |
| **[EJECUTAR.ps1](EJECUTAR.ps1)** | ▶️ Script de ejecución de pruebas |
| **[CAPTURAR_COOKIE.ps1](CAPTURAR_COOKIE.ps1)** | 🔑 Script de captura de cookie |

## ⚡ Inicio Rápido

### 1️⃣ Instalación (Primera vez)

Abre PowerShell como **Administrador** y ejecuta:

```powershell
cd c:\Users\Gabriel\.gemini\antigravity\scratch\prueba_carga
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\INSTALL.ps1
```

### 2️⃣ Capturar Cookie

```powershell
.\CAPTURAR_COOKIE.ps1
```

O manualmente:
1. Abre Chrome y tu aplicación
2. Inicia sesión
3. F12 → Application → Cookies → Copia PHPSESSID
4. Edita `.env` → `AUTH_COOKIE="PHPSESSID=valor"`

### 3️⃣ Ejecutar Pruebas

```powershell
# Menú interactivo
.\EJECUTAR.ps1

# O directamente
.\EJECUTAR.ps1 smoke -ConReporte
```

## 📊 Tipos de Pruebas Disponibles

| Tipo | Duración | Carga | Propósito |
|------|----------|-------|-----------|
| **Smoke** | 10s | 1 usuario/seg | Validación rápida |
| **Stress** | 5min | 1→20 usuarios/seg | Encontrar límites |
| **Production** | 8min | 2→50 usuarios/seg | Simular producción |

## 🔑 Variables de Entorno (.env)

```env
TARGET_URL=https://escalamientosnaturaha.grupokonecta.local
AUTH_COOKIE="PHPSESSID=7d6ok7rq9er6v6tfbgvnsb87ne"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64)..."
ARTILLERY_CLOUD_API_KEY=tu_api_key
```

## 📚 Documentación

- **Primera vez**: Lee [GUIA_COMPLETA.md](GUIA_COMPLETA.md)
- **Uso diario**: Consulta [REFERENCIA_RAPIDA.md](REFERENCIA_RAPIDA.md)
- **Artillery Docs**: https://artillery.io/docs

## 🛠️ Comandos Principales

```powershell
# Instalación
.\INSTALL.ps1

# Capturar cookie
.\CAPTURAR_COOKIE.ps1

# Ejecutar prueba (interactivo)
.\EJECUTAR.ps1

# Ejecutar prueba específica
.\EJECUTAR.ps1 smoke -ConReporte
.\EJECUTAR.ps1 stress -ConReporte
.\EJECUTAR.ps1 production -Cloud -ConReporte

# Ver reporte
artillery report report_smoke.json

# Generar HTML
node generate-report.js report_smoke.json report_smoke.html
```

## 🎯 Flujo de Trabajo Recomendado

```
1. INSTALL.ps1          → Instalar todo (una sola vez)
2. CAPTURAR_COOKIE.ps1  → Obtener cookie (cuando expire)
3. EJECUTAR.ps1         → Ejecutar pruebas
4. Revisar reporte HTML → Analizar resultados
```

## ✅ Verificación

```powershell
# Verificar instalación
node --version
npm --version
artillery --version

# Verificar configuración
Get-Content .env
```

## 🆘 Solución de Problemas

### Error: "artillery: command not found"
```powershell
npm install -g artillery
```

### Error: 401 Unauthorized
- Cookie expirada → Captura nueva cookie

### Error: ECONNREFUSED
- Verifica TARGET_URL en .env
- Verifica que el servidor esté activo

Ver más en [GUIA_COMPLETA.md](GUIA_COMPLETA.md#7-solución-de-problemas)

## 📈 Métricas Clave

| Métrica | Ideal | Aceptable |
|---------|-------|-----------|
| Response Time (median) | < 500ms | < 1000ms |
| Response Time (p95) | < 1000ms | < 2000ms |
| Código 200 | 100% | > 95% |
| Usuarios fallidos | 0 | < 1% |

## 🔐 Seguridad

- ⚠️ No subas `.env` a Git (ya está en `.gitignore`)
- ⚠️ Las cookies expiran, actualízalas regularmente
- ⚠️ Coordina pruebas intensivas con tu equipo

## 📝 Archivos Generados

```
report_smoke_20260210_142345.json   → Resultados en JSON
report_smoke_20260210_142345.html   → Reporte visual
responses.log                        → Log de respuestas
```

---

**¿Primera vez?** → Lee [GUIA_COMPLETA.md](GUIA_COMPLETA.md)

**¿Usuario experimentado?** → Consulta [REFERENCIA_RAPIDA.md](REFERENCIA_RAPIDA.md)

**¿Listo para empezar?** → Ejecuta `.\INSTALL.ps1`
