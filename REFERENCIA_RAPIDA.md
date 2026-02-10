# 📋 REFERENCIA RÁPIDA - COMANDOS DE PRUEBAS DE CARGA

## 🚀 Instalación Inicial

```powershell
# Ejecutar script de instalación (una sola vez)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\INSTALL.ps1
```

## 🔑 Captura de Cookie

```powershell
# Método 1: Script interactivo
.\CAPTURAR_COOKIE.ps1

# Método 2: Manual en Chrome
# 1. F12 → Application → Cookies → Copiar PHPSESSID
# 2. Editar .env → AUTH_COOKIE="PHPSESSID=valor"
```

## ▶️ Ejecución de Pruebas

### Menú Interactivo (Recomendado)

```powershell
.\EJECUTAR.ps1
```

### Comandos Directos

```powershell
# Smoke Test (10s, 1 usuario/seg)
.\EJECUTAR.ps1 smoke -ConReporte

# Stress Test (5min, 1-20 usuarios/seg)
.\EJECUTAR.ps1 stress -ConReporte

# Production Test (8min, 2-50 usuarios/seg)
.\EJECUTAR.ps1 production -ConReporte

# En Artillery Cloud
.\EJECUTAR.ps1 smoke -Cloud -ConReporte
```

### Comandos Artillery Nativos

```powershell
# Ejecutar con ambiente específico
artillery run --environment smoke --output report.json artillery-admin.yml

# Ver reporte en consola
artillery report report.json

# Generar reporte HTML
node generate-report.js report.json report.html
```

## 📊 Verificación Rápida

```powershell
# Ver versiones instaladas
node --version
npm --version
artillery --version

# Ver últimos logs
Get-Content responses.log -Tail 50

# Listar reportes generados
Get-ChildItem -Filter "report_*.json" | Sort-Object LastWriteTime -Descending
Get-ChildItem -Filter "report_*.html" | Sort-Object LastWriteTime -Descending
```

## 🔧 Solución de Problemas

```powershell
# Reinstalar Artillery
npm uninstall -g artillery
npm install -g artillery

# Reinstalar dependencias del proyecto
Remove-Item -Recurse -Force node_modules
npm install

# Verificar configuración .env
Get-Content .env

# Probar conectividad
curl https://escalamientosnaturaha.grupokonecta.local
```

## 📁 Estructura de Archivos

```
prueba_carga/
├── INSTALL.ps1              # Script de instalación
├── EJECUTAR.ps1             # Script de ejecución
├── CAPTURAR_COOKIE.ps1      # Script de captura de cookie
├── GUIA_COMPLETA.md         # Guía completa (léeme primero)
├── REFERENCIA_RAPIDA.md     # Esta referencia rápida
├── .env                     # Configuración (URL, cookie, etc.)
├── .env.example             # Plantilla de configuración
├── artillery-admin.yml      # Configuración de pruebas
├── processor.js             # Lógica de Artillery
├── generate-report.js       # Generador de reportes
├── report-template.html     # Plantilla de reporte
└── report_*.json/html       # Reportes generados
```

## 💡 Flujo de Trabajo Típico

```powershell
# 1. Primera vez (solo una vez)
.\INSTALL.ps1

# 2. Capturar cookie (cuando expire)
.\CAPTURAR_COOKIE.ps1

# 3. Ejecutar prueba
.\EJECUTAR.ps1 smoke -ConReporte

# 4. Ver resultado
# Se abrirá automáticamente el reporte HTML
```

## 🎯 Métricas Objetivo

| Métrica | Ideal | Aceptable | Problemático |
|---------|-------|-----------|--------------|
| Response Time (median) | < 500ms | 500-1000ms | > 1000ms |
| Response Time (p95) | < 1000ms | 1000-2000ms | > 2000ms |
| Código 200 | 100% | > 95% | < 95% |
| Usuarios fallidos | 0 | < 1% | > 1% |

## ⚙️ Variables de Entorno (.env)

```env
# Requeridas
TARGET_URL=https://tu-servidor.com
AUTH_COOKIE="PHPSESSID=valor_de_cookie"

# Opcionales
USER_AGENT="Mozilla/5.0 ..."
ARTILLERY_CLOUD_API_KEY=tu_api_key
```

## 🌐 Artillery Cloud

```powershell
# Configurar API Key
# Agregar a .env:
# ARTILLERY_CLOUD_API_KEY=tu_api_key

# Ejecutar en cloud
.\EJECUTAR.ps1 smoke -Cloud

# Ver dashboards en:
# https://app.artillery.io
```

## 📞 Ayuda

```powershell
# Mostrar ayuda del script
.\EJECUTAR.ps1 -Help

# Ayuda de Artillery
artillery help
artillery run --help

# Ver guía completa
notepad GUIA_COMPLETA.md
```

---

**Documentación completa**: Ver [GUIA_COMPLETA.md](GUIA_COMPLETA.md)
