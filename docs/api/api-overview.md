# Visión general de la API — BankOS

> **Estado (2026-11-17):** implementada y publicada con OpenAPI. La fuente canónica está en [`backend/docs/api/api-overview.md`](../../backend/docs/api/api-overview.md).

## Base

- **URL local:** `http://localhost:8080`
- **Base path:** `/api/v1`
- **Formato:** JSON, nombres `snake_case`
- **OpenAPI:** `/v3/api-docs`
- **Swagger UI:** `/swagger-ui.html`
- **Health:** `/actuator/health`

## Autenticación

1. `POST /api/v1/auth/login` con `tenant_code`, `email` y `password`.
2. Guardar un token por institución.
3. Enviar `Authorization: Bearer <token>` en cada llamada.
4. El backend extrae `tenant_id` y roles del JWT.

No se acepta `tenant_id` desde el body ni query params.

## Headers

| Header | Uso |
|---|---|
| `Authorization` | JWT de la institución activa. |
| `X-Correlation-ID` | Trazabilidad; el backend genera uno si falta. |
| `Idempotency-Key` | Obligatorio en depósitos, retiros y transferencias. |

## Respuesta exitosa

```json
{
  "success": true,
  "code": "DEPOSIT_COMPLETED",
  "message": "Depósito realizado correctamente",
  "data": {},
  "correlation_id": "..."
}
```

## Respuesta de error

```json
{
  "success": false,
  "code": "VALIDATION_ERROR",
  "message": "La solicitud contiene errores",
  "data": null,
  "correlation_id": "..."
}
```

## Endpoints

| Método | Ruta | Descripción |
|---|---|---|
| `POST` | `/auth/login` | Login por institución |
| `GET` | `/auth/me` | Usuario y tenant actuales |
| `GET/POST` | `/tenants` | Instituciones |
| `GET/POST` | `/users` | Usuarios del tenant |
| `GET/POST` | `/customers` | Clientes |
| `GET/POST` | `/accounts` | Cuentas |
| `GET/PUT` | `/settings` | Configuración |
| `GET/POST` | `/settings/exchange-rates` | Tasas |
| `POST` | `/transactions/deposits` | Depósito |
| `POST` | `/transactions/withdrawals` | Retiro |
| `POST` | `/transactions/transfers` | Transferencia |
| `POST` | `/transactions/transfers/preview` | Preview |
| `GET` | `/transactions` | Historial |
| `GET` | `/transactions/{id}` | Detalle |
| `GET` | `/audit-logs` | Auditoría |
| `GET/POST` | `/webhooks` | Webhooks |
| `GET` | `/webhooks/events` | Outbox |

## Paginación

Parámetros `page`, `size`, `sort`. Respuesta:

```json
{
  "items": [],
  "page": 0,
  "size": 20,
  "total_elements": 0,
  "total_pages": 0
}
```

## Documentación relacionada

- [API overview detallada](../../backend/docs/api/api-overview.md)
- [Contratos](api-contracts.md)
- [Errores](error-handling.md)
- [Autenticación](../security/authentication.md)
