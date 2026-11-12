# Visión general de la API — BankOS

## Estado
- **Implementado (auditado):** No hay API implementada. No existen controladores, rutas, ni especificación OpenAPI/Swagger en el repositorio.
- **Decisión objetivo:** API REST sobre HTTP con JSON, versionada bajo `/api/v1`.

## Convenciones generales

- **Base path:** `/api/v1`
- **Formato:** JSON (`Content-Type: application/json`)
- **Autenticación:** JWT Bearer (cuando el endpoint lo requiera)
- **Trazabilidad:** `X-Correlation-ID` (UUID) en solicitudes y respuestas
- **Idempotencia:** `Idempotency-Key` (UUID) en operaciones financieras; reintentos deben conservar **la misma llave y el mismo cuerpo**

### Headers

**Generales:**
```http
Content-Type: application/json
X-Correlation-ID: <UUID>
Authorization: Bearer <JWT>
```

**Operaciones financieras (adicional):**
```http
Idempotency-Key: <UUID>
X-Correlation-ID: <UUID>
```

## Formato de respuesta estandarizado (objetivo)

**Éxito:**
```json
{
  "success": true,
  "code": "OPERATION_SUCCESS",
  "message": "Operación realizada correctamente",
  "data": {},
  "correlation_id": "uuid"
}
```

**Error:**
```json
{
  "success": false,
  "code": "INSUFFICIENT_FUNDS",
  "message": "Saldo insuficiente",
  "data": null,
  "correlation_id": "uuid"
}
```

> Los códigos (`code`) concretos por endpoint son **propuestos/pendientes** y deben mantenerse consistentes entre backend y frontend.

## Dominios funcionales (objetivo)

La API debe cubrir contratos para:
- Tenants
- Autenticación
- Usuarios
- Clientes (customers)
- Cuentas
- Depósitos
- Retiros
- Transferencias
- Preview de transferencias
- Historial
- Configuración (settings)
- Auditoría
- Webhooks

El detalle por endpoint se documenta en [Contratos de API](api-contracts.md).

## Seguridad y multitenancy en la API

- El `tenant` se determina desde el **contexto autenticado** (JWT/filtros de seguridad), nunca desde datos enviados por el cliente.
- Autorización y validación de permisos se realizan en el backend.
- Accesos a recursos de otro tenant deben ser denegados.
- No se deben exponer entidades JPA ni detalles internos sensibles en respuestas.

## Versionado y evolución

- Cambios incompatibles deben gestionarse mediante versionado (p. ej. `/api/v2`) o estrategia acordada. **Pendiente de definir política formal.**
- Los contratos deben actualizarse en documentación antes o junto con la implementación.

## Documentación OpenAPI/Swagger

- **Estado actual:** No configurado.
- **Objetivo:** Generar y exponer especificación OpenAPI en desarrollo para facilitar integración con Flutter y pruebas. 
