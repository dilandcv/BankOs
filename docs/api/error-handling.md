# Manejo de errores — BankOS

> **Estado (2026-11-17):** implementado en el backend. La fuente canónica está en [`backend/docs/api/error-handling.md`](../../backend/docs/api/error-handling.md).

## Formato

Todas las respuestas de error usan el mismo sobre:

```json
{
  "success": false,
  "code": "ACCOUNT_NOT_FOUND",
  "message": "Cuenta no encontrada",
  "data": null,
  "correlation_id": "7f4c3d2e-..."
}
```

- `code` es estable y apto para lógica del cliente.
- `message` es legible para humanos.
- `correlation_id` permite correlacionar con logs.
- No se exponen stack traces ni detalles internos.

## Códigos HTTP

| HTTP | Uso |
|---|---|
| `400` | Validación, headers faltantes o parámetros inválidos. |
| `401` | Credenciales inválidas o token ausente/expirado. |
| `403` | Autenticado sin permiso. |
| `404` | Recurso inexistente o de otro tenant. |
| `409` | Conflicto de idempotencia o estado. |
| `422` | Regla de negocio no satisfecha. |
| `500` | Error no controlado. |
| `503` | Dependencia no disponible. |

## Códigos de negocio principales

`VALIDATION_ERROR`, `INVALID_CREDENTIALS`, `UNAUTHORIZED`, `FORBIDDEN`, `TENANT_NOT_FOUND`, `USER_NOT_FOUND`, `CUSTOMER_NOT_FOUND`, `ACCOUNT_NOT_FOUND`, `ACCOUNT_NOT_ACTIVE`, `INSUFFICIENT_FUNDS`, `CURRENCY_MISMATCH`, `EXCHANGE_RATE_NOT_FOUND`, `IDEMPOTENCY_KEY_REQUIRED`, `IDEMPOTENCY_CONFLICT`, `TRANSACTION_NOT_FOUND`, `WEBHOOK_NOT_FOUND`, `INTERNAL_ERROR`.

## Idempotencia

- Falta `Idempotency-Key` → `400 IDEMPOTENCY_KEY_REQUIRED`.
- Misma llave + mismo cuerpo → `200` con la respuesta original.
- Misma llave + cuerpo distinto → `409 IDEMPOTENCY_CONFLICT`.

## Aislamiento

Un recurso de otro tenant responde `404` para no revelar su existencia.

## Frontend

- Mapear `code` a mensajes de UI; no mostrar `message` técnico sin contexto.
- Conservar `correlation_id` en reportes de soporte.
- No reintentar operaciones financieras con una llave distinta si ya se envió una.
- Renovar sesión solo si existe refresh token (pendiente).

## Documentación relacionada

- [Manejo de errores del backend](../../backend/docs/api/error-handling.md)
- [Contratos](api-contracts.md)
- [API overview](api-overview.md)
