# 🔧 Corrección: Endpoint Performance Table

## Problema Identificado
La tabla "🎯 Endpoint Performance" no mostraba datos porque la función de extracción buscaba el patrón incorrecto.

## Causa Raíz
Artillery con el plugin `metrics-by-endpoint` guarda las métricas con el formato:
```
plugins.metrics-by-endpoint.response_time./admin/app-config/index
```

Pero mi código original buscaba:
```
http.response_time.GET /endpoint
```

## Solución Implementada

Actualicé la función `extractEndpointMetrics()` en `generate-report.js` para:

1. **Buscar primero el patrón de Artillery plugin**:
   ```javascript
   plugins\.metrics-by-endpoint\.response_time\.(.+)$
   ```

2. **Mantener compatibilidad con formato estándar**:
   ```javascript
   http\.response_time\.(GET|POST|PUT|DELETE|PATCH)\s+(.+)$
   ```

## Archivos Modificados
- [`generate-report.js`](file:///c:/Users/Gabriel/.gemini/antigravity/scratch/prueba_carga/generate-report.js) - Función `extractEndpointMetrics()` actualizada

## Cómo Probar

Regenera el reporte desde cualquier JSON existente:

```bash
node generate-report.js report_smoke_admin.json
```

Ahora al abrir `report_smoke_admin.html` verás la tabla completa con todos los endpoints:
- `/admin/app-config/index`
- `/admin/boveda-secretos/index`
- `/admin/casos-gestionados`
- `/admin/clasificaciones/index`
- `/admin/dashboard/index`
- Y todos los demás endpoints...

Cada uno con sus métricas completas: Min, Median, P95, P99, Max

## ✅ Status
El problema está **resuelto**. La tabla ahora mostrará correctamente todas las métricas por endpoint.
