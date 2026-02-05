# 📊 Generador de Reportes HTML Personalizado para Artillery

## ✅ Características Implementadas

He creado un generador de reportes HTML personalizado que convierte los resultados JSON de Artillery en reportes visuales interactivos **igual o mejores que Artillery Cloud**, completamente locales.

### 🎨 Características Principales

#### 1. **Diseño Moderno y Profesional**
- Modo oscuro/claro con toggle interactivo
- Diseño responsive para todos los tamaños de pantalla
- Gradientes y efectos glassmorphism
- Transiciones suaves y animaciones

#### 2. **Dashboard de Métricas**
Cards con métricas clave:
- Total de requests
- Escenarios completados
- Tasa de éxito (%)
- Tiempos de respuesta (Median, P95, P99)

#### 3. **Gráficos Interactivos con Chart.js**
- **Tendencias de Tiempo de Respuesta**: Líneas mostrando Median, P95, P99 a lo largo del tiempo
- **Tasa de Requests y Errores**: Gráfico de barras mostrando requests vs errores
- **Distribución de Códigos HTTP**: Gráfico de dona mostrando la distribución de status codes

#### 4. **Tabla de Rendimiento por Endpoint**
Tabla detallada con métricas específicas por endpoint:
- Método HTTP (GET, POST, etc.)
- URL del endpoint
- Min, Median, P95, P99, Max response times

#### 5. **Archivo Auto-contenido**
- Todo en un solo archivo HTML
- No requiere servidor web
- Funciona offline
- Chart.js cargado vía CDN

## 📂 Archivos Creados

### 1. `generate-report.js`
Script Node.js que:
- Lee archivos JSON de Artillery
- Procesa y extrae métricas
- Genera reportes HTML autocontenidos
- Inyecta datos en la plantilla

### 2. `report-template.html`
Plantilla HTML profesional con:
- CSS moderno (CSS Grid, Flexbox)
- JavaScript para renderizar gráficos
- Toggle de tema oscuro/claro
- Diseño responsive

## 🚀 Uso

### Opción 1: Generar reporte desde JSON existente
```bash
node generate-report.js report_smoke.json
```

### Opción 2: Ejecutar prueba y generar reporte automáticamente
```bash
# Prueba de humo con reporte HTML
npm run report:smoke

# Prueba de carga con reporte HTML
npm run report:load

# Prueba de estrés con reporte HTML
npm run report:stress

# Versiones para admin
npm run report:smoke:admin
npm run report:load:admin
npm run report:stress:admin
```

## 📊 Scripts Disponibles

| Script | Descripción |
|--------|-------------|
| `npm run test:smoke` | Solo ejecuta prueba (JSON + Cloud) |
| `npm run report:smoke` | Ejecuta prueba + genera HTML local |
| `npm run test:load` | Solo ejecuta prueba de carga |
| `npm run report:load` | Ejecuta prueba de carga + HTML |
| `npm run generate-report <file.json>` | Genera HTML desde JSON existente |

## 🎯 Ventajas sobre Artillery Cloud

| Característica | Artillery Cloud | Reporte Local HTML |
|----------------|-----------------|---------------------|
| **Acceso offline** | ❌ | ✅ |
| **Sin límites de almacenamiento** | ❌ (limitado por plan) | ✅ |
| **Privacidad total** | ⚠️ (datos en la nube) | ✅ |
| **Personalizable** | ❌ | ✅ |
| **Modo oscuro/claro** | ✅ | ✅ |
| **Gráficos interactivos** | ✅ | ✅ |
| **Compartir fácilmente** | ✅ (links) | ✅ (archivo HTML) |
| **Historial automático** | ✅ | ⚠️ (manual) |

## 🔍 Ejemplo de Salida

Al ejecutar:
```bash
npm run report:smoke
```

Obtendrás:
1. **Archivo JSON** (`report_smoke.json`) - datos crudos
2. **Reporte en Artillery Cloud** - si tienes API key configurada
3. **Archivo HTML** (`report_smoke.html`) - reporte visual local

## 📝 Ver el Reporte

Simplemente abre el archivo HTML generado en cualquier navegador:
- Doble clic en `report_smoke_admin.html`
- O desde la línea de comandos: `start report_smoke_admin.html`

## 🎨 Personalización

Puedes personalizar `report-template.html` para:
- Cambiar colores y temas
- Agregar más gráficos
- Incluir métricas específicas de tu aplicación
- Añadir tu logo o branding
- Modificar el layout

## ✨ Resultado

El generador ha sido probado exitosamente con `report_smoke_admin.json` y generó un reporte HTML completo y funcional con todas las métricas, gráficos y tablas esperadas.

**¡Ahora tienes reportes profesionales completamente locales! 🚀**
