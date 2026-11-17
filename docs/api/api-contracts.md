# Contratos de API — BankOS

> **Estado:** implementado en el backend. La fuente detallada y vigente está en [`backend/docs/api/api-contracts.md`](../../backend/docs/api/api-contracts.md) y en OpenAPI (`/v3/api-docs`). `mobile/` todavía no consume estos endpoints.

## Convenciones

- **Base path:** `/api/v1`
- **Content-Type:** `application/json`
- **Headers generales:** `Authorization: Bearer <JWT>`, `X-Correlation-ID`
- **Operaciones financieras:** `Idempotency-Key` obligatorio; conservar llave y cuerpo en reintentos.
- **Respuestas:** `success`, `code`, `message`, `data`, `correlation_id`.
- **Tenant:** se extrae del JWT; **no** se envía ni se confía `tenant_id` desde el cliente.
- **Dinero:** `BigDecimal` serializado como string; `NUMERIC(19,4)`.
- **JSON:** `snake_case`.

## Login multi-banco

```http
POST /api/v1/auth/login
```

```json
{
  "tenant_code": "BANCO_HORIZONTE",
  "email": "admin@horizonte.com",
  "password": "Admin123!"
}
```

La respuesta incluye `access_token`, `expires_in`, `user` y `tenant` con `primary_color`, `secondary_color` y `logo_url`. El cliente debe guardar un token por `tenant_code`.

## Endpoints implementados

| Método | Ruta | Descripción | Roles |
|---|---|---|---|
| `POST` | `/api/v1/auth/login` | Login por institución | Público |
| `GET` | `/api/v1/auth/me` | Usuario y tenant actuales | Autenticado |
| `GET/POST` | `/api/v1/tenants` | Instituciones | Según rol |
| `GET/POST` | `/api/v1/users` | Usuarios del tenant | `TENANT_ADMIN` / `PLATFORM_ADMIN` |
| `GET/POST` | `/api/v1/customers` | Clientes del tenant | `TENANT_ADMIN`, `OPERATOR` |
| `GET/POST` | `/api/v1/accounts` | Cuentas del tenant | `TENANT_ADMIN`, `OPERATOR` |
| `GET/PUT` | `/api/v1/settings` | Configuración del tenant | `TENANT_ADMIN` |
| `GET/POST` | `/api/v1/settings/exchange-rates` | Tasas de cambio | `TENANT_ADMIN` |
| `POST` | `/api/v1/transactions/deposits` | Depósito idempotente | `TENANT_ADMIN`, `OPERATOR` |
| `POST` | `/api/v1/transactions/withdrawals` | Retiro idempotente | `TENANT_ADMIN`, `OPERATOR` |
| `POST` | `/api/v1/transactions/transfers` | Transferencia idempotente | `TENANT_ADMIN`, `OPERATOR` |
| `POST` | `/api/v1/transactions/transfers/preview` | Cálculo de tasa/comisión | Todos los roles |
| `GET` | `/api/v1/transactions` | Historial con filtros | Todos los roles |
| `GET` | `/api/v1/transactions/{id}` | Detalle de transacción | Todos los roles |
| `GET` | `/api/v1/audit-logs` | Auditoría del tenant | `PLATFORM_ADMIN`, `TENANT_ADMIN`, `AUDITOR` |
| `GET/POST` | `/api/v1/webhooks` | Configuración de webhooks | `PLATFORM_ADMIN`, `TENANT_ADMIN` |
| `GET` | `/api/v1/webhooks/events` | Outbox de eventos | `PLATFORM_ADMIN`, `TENANT_ADMIN` |

## Operaciones financieras

### Depósito

```http
POST /api/v1/transactions/deposits
Idempotency-Key: 7f4c3d2e-1111-2222-3333-444455556666
```

```json
{
  "account_id": "30000000-0000-0000-0000-000000000001",
  "amount": "100.00",
  "currency": "USD",
  "description": "Depósito demo"
}
```

### Retiro

```http
POST /api/v1/transactions/withdrawals
Idempotency-Key: ...
```

```json
{
  "account_id": "30000000-0000-0000-0000-000000000002",
  "amount": "25.00",
  "currency": "USD",
  "description": "Retiro demo"
}
```

### Transferencia

```http
POST /api/v1/transactions/transfers
Idempotency-Key: ...
```

```json
{
  "source_account_id": "30000000-0000-0000-0000-000000000001",
  "target_account_id": "30000000-0000-0000-0000-000000000003",
  "amount": "10.00",
  "currency": "USD",
  "description": "Transferencia demo"
}
```

### Preview

```http
POST /api/v1/transactions/transfers/preview
```

```json
{
  "source_account_id": "30000000-0000-0000-0000-000000000001",
  "target_account_id": "30000000-0000-0000-0000-000000000003",
  "amount": "10.00",
  "currency": "USD"
}
```

## Historial

```http
GET /api/v1/transactions?page=0&size=20&accountId=<uuid>&type=DEPOSIT&from=2026-01-01T00:00:00Z&to=2026-12-31T23:59:59Z
```

Todos los filtros son opcionales. Orden por defecto: `created_at DESC`. Tipos: `DEPOSIT`, `WITHDRAWAL`, `TRANSFER`.

## Idempotencia

- Misma llave + mismo cuerpo → misma respuesta.
- Misma llave + cuerpo distinto → `409 IDEMPOTENCY_CONFLICT`.
- Llave ausente → `400 IDEMPOTENCY_KEY_REQUIRED`.
- La llave es única por tenant y operación.

## Errores

```json
{
  "success": false,
  "code": "ACCOUNT_NOT_FOUND",
  "message": "Cuenta no encontrada",
  "data": null,
  "correlation_id": "..."
}
```

Códigos principales: `VALIDATION_ERROR`, `INVALID_CREDENTIALS`, `UNAUTHORIZED`, `FORBIDDEN`, `ACCOUNT_NOT_FOUND`, `INSUFFICIENT_FUNDS`, `CURRENCY_MISMATCH`, `EXCHANGE_RATE_NOT_FOUND`, `IDEMPOTENCY_CONFLICT`, `INTERNAL_ERROR`.

## Documentación detallada

- [Contratos completos del backend](../../backend/docs/api/api-contracts.md)
- [Visión general de la API](../../backend/docs/api/api-overview.md)
- [Manejo de errores](../../backend/docs/api/error-handling.md)
- [OpenAPI](http://localhost:8080/v3/api-docs)
