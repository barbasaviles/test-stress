# Configuración de Artillery Cloud

## ✅ Cambios Realizados

He actualizado tu proyecto para que **suba automáticamente los reportes a Artillery Cloud** cuando terminen las pruebas.

### Archivos modificados:

1. **`.env.example`** - Agregada variable `ARTILLERY_CLOUD_API_KEY`
2. **`package.json`** - Todos los scripts ahora incluyen el flag `--record`

## 📋 Pasos para Configurar Artillery Cloud

### 1. Crear una cuenta en Artillery Cloud

1. Ve a **https://app.artillery.io/**
2. Regístrate o inicia sesión con tu cuenta de GitHub/Google

### 2. Obtener tu API Key

1. Una vez dentro, ve a **Settings** (Configuración)
2. Busca la sección **API Keys**
3. Copia tu API Key personal

### 3. Configurar tu archivo `.env`

Abre tu archivo `.env` (si no existe, copia `.env.example` a `.env`) y agrega:

```bash
ARTILLERY_CLOUD_API_KEY=tu_api_key_aqui
```

> ⚠️ **Importante**: No compartas tu API Key públicamente. Asegúrate de que `.env` esté en tu `.gitignore`

## 🚀 Cómo Usar

Ahora cuando ejecutes cualquiera de tus scripts de prueba, Artillery:

1. ✅ Ejecutará las pruebas como siempre
2. ✅ Guardará el reporte JSON local (para análisis programático)
3. ✅ **Subirá automáticamente los resultados a Artillery Cloud**

### Ejemplo de ejecución:

```bash
npm run test:smoke
```

Al finalizar, verás un mensaje similar a:

```
Test run recorded and uploaded to https://app.artillery.io/runs/abc123xyz
```

> 📝 **Nota**: El comando `artillery report` para generar HTML local ha sido deprecado. Los reportes visuales solo están disponibles en Artillery Cloud.

## 📊 Ver tus Reportes en la Nube

1. Abre **https://app.artillery.io/runs**
2. Verás todos tus test runs con:
   - Gráficos interactivos de rendimiento
   - Métricas detalladas por endpoint
   - Comparaciones entre diferentes ejecuciones
   - Análisis de tendencias

## 🔍 Ventajas de Artillery Cloud

- **Histórico de pruebas**: Guarda todas tus ejecuciones
- **Comparaciones**: Compara resultados entre diferentes versiones
- **Colaboración**: Comparte reportes con tu equipo mediante URL
- **Análisis avanzado**: Gráficos interactivos y métricas profundas
- **Alertas**: Configura alertas cuando el rendimiento se degrada

## 🛠️ Comandos Disponibles

Todos estos comandos ahora suben a la nube:

| Comando | Descripción |
|---------|-------------|
| `npm run test:smoke` | Prueba de humo básica |
| `npm run test:load` | Prueba de carga producción |
| `npm run test:stress` | Prueba de estrés |
| `npm run test:smoke:admin` | Prueba de humo para admin |
| `npm run test:load:admin` | Prueba de carga para admin |
| `npm run test:stress:admin` | Prueba de estrés para admin |

## 📤 Subida Manual de Reportes Existentes

Si tienes un reporte JSON generado localmente que no fue grabado automáticamente, puedes subirlo manualmente con:

```bash
npm run publish:cloud <ruta-de-archivo.json>
```

**Ejemplo:**
```bash
npm run publish:cloud report_smoke_admin.json
```

---
## 📝 Notas

- Los reportes locales (JSON y HTML) se siguen generando normalmente
- El flag `--record` es lo que activa la subida a la nube
- Puedes ver el progreso de la subida en la consola durante la ejecución
