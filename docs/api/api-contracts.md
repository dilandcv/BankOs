# Contratos de API — BankOS

> **Estado:** **No implementado / Propuesto.** No existen endpoints en el repositorio. Los contratos siguientes definen el objetivo inicial y deben validarse/ajustarse por el equipo antes y durante la implementación. Ningún contrato debe considerarse vigente hasta ser implementado y probado.

## Convenciones aplicables a todos los endpoints
- **Base path:** `/api/v1`
- **Content-Type:** `application/json`
- **Headers generales:** `X-Correlation-ID: <UUID>`, `Authorization: Bearer <JWT>` (excepto login u otros públicos que se definan).
- **Operaciones financieras:** incluir `Idempotency-Key: <UUID>` y conservar misma llave/cuerpo en reintentos.
- **Respuestas:** Formato estandarizado (`success`, `code`, `message`, `data`, `correlation_id`).
- **Tenant:** Derivado del contexto autenticado; **no** se envía ni se confía `tenant_id` desde Flutter.

---

## 1. Tenants (propuesto)

| Campo | Valor |
|---|---|
| Método | `POST` |
| Ruta | `/api/v1/tenants` |
| Descripción | Registrar/crear una institución (alcance administrativo; definir si es público o restringido). |
| Permisos | **Pendiente** (p. ej. admin plataforma). |
| Headers | `Content-Type`, `X-Correlation-ID` |

**Request (ejemplo propuesto):**
```json
{
  "name": "Banco Ejemplo",
  "code": "BANCO_EJEMPLO"
}
```
**Response 201 (ejemplo):**
```json
{
  "success": true,
  "code": "TENANT_CREATED",
  "message": "Tenant creado",
  "data": { "id": "uuid", "name": "Banco Ejemplo", "status": "ACTIVE" },
  "correlation_id": "uuid"
}
```
**Errores posibles:** `VALIDATION_ERROR`, `TENANT_ALREADY_EXISTS`, `UNAUTHORIZED`, `FORBIDDEN`, `INTERNAL_ERROR`.

| Método | `GET` | Ruta | `/api/v1/tenants/{id}` | Descripción | Obtener información de tenant (según permisos). | Permisos | **Pendiente** |
|---|---|---|---|---|---|---|---|
**Errores:** `TENANT_NOT_FOUND`, `UNAUTHORIZED`, `FORBIDDEN`.

> **Pendiente:** Definir endpoints de listado/actualización y reglas de administración.

## 2. Autenticación (propuesto)

| Campo | Valor |
|---|---|
| Método | `POST` |
| Ruta | `/api/v1/auth/login` |
| Descripción | Autenticar usuario y emitir JWT. |
| Permisos | Público (credenciales válidas). |
| Headers | `Content-Type`, `X-Correlation-ID` |

**Request (ejemplo propuesto):**
```json
{
  "username": "usuario",
  "password": "secreto"
}
```
**Response 200 (ejemplo):**
```json
{
  "success": true,
  "code": "AUTH_SUCCESS",
  "message": "Autenticación exitosa",
  "data": {
    "access_token": "jwt",
    "token_type": "Bearer",
    "expires_in": 3600
  },
  "correlation_id": "uuid"
}
```
**Errores:** `INVALID_CREDENTIALS`, `TENANT_INACTIVE`, `USER_INACTIVE`, `VALIDATION_ERROR`, `RATE_LIMITED`.

> **Pendiente:** Refresh token, logout, expiración y claims exactos del JWT.

## 3. Usuarios (propuesto)

| Método | Ruta | Descripción | Permisos |
|---|---|---|---|
| `POST` | `/api/v1/users` | Crear usuario en el tenant autenticado | Admin de tenant (pendiente) |
| `GET` | `/api/v1/users` | Listar usuarios del tenant | Admin (pendiente) |
| `GET` | `/api/v1/users/{id}` | Obtener usuario | Admin/self (pendiente) |

**Headers:** `Content-Type`, `X-Correlation-ID`, `Authorization`  
**Errores:** `VALIDATION_ERROR`, `USER_NOT_FOUND`, `UNAUTHORIZED`, `FORBIDDEN`, `CONFLICT`.

## 4. Clientes / Customers (propuesto)

| Método | Ruta | Descripción | Permisos |
|---|---|---|---|
| `POST` | `/api/v1/customers` | Crear cliente | Según rol (pendiente) |
| `GET` | `/api/v1/customers` | Listar clientes del tenant | Según rol |
| `GET` | `/api/v1/customers/{id}` | Detalle de cliente | Según rol |

**Errores:** `VALIDATION_ERROR`, `CUSTOMER_NOT_FOUND`, `UNAUTHORIZED`, `FORBIDDEN`.

## 5. Cuentas (propuesto)

| Método | Ruta | Descripción | Permisos |
|---|---|---|---|
| `POST` | `/api/v1/accounts` | Crear cuenta | Según rol |
| `GET` | `/api/v1/accounts` | Listar cuentas del tenant (filtros pendientes) | Según rol |
| `GET` | `/api/v1/accounts/{id}` | Detalle y saldo de cuenta | Según rol y pertenencia al tenant |

**Response data (ejemplo):** `{ "id": "uuid", "customer_id": "uuid", "currency": "USD", "balance": "1000.00", "status": "ACTIVE" }`  
**Errores:** `ACCOUNT_NOT_FOUND`, `ACCOUNT_INACTIVE`, `UNAUTHORIZED`, `FORBIDDEN`.

## 6. Depósitos (propuesto)

| Campo | Valor |
|---|---|
| Método | `POST` |
| Ruta | `/api/v1/transactions/deposits` |
| Descripción | Acreditar fondos a una cuenta. |
| Permisos | Según rol (pendiente). |
| Headers | `Content-Type`, `X-Correlation-ID`, `Authorization`, `Idempotency-Key` |

**Request (ejemplo):**
```json
{
  "account_id": "uuid",
  "amount": "100.00",
  "currency": "USD",
  "description": "Depósito en ventanilla"
}
```
**Errores:** `ACCOUNT_NOT_FOUND`, `ACCOUNT_INACTIVE`, `ACCOUNT_BLOCKED`, `VALIDATION_ERROR`, `IDEMPOTENCY_CONFLICT`, `UNAUTHORIZED`, `FORBIDDEN`.

## 7. Retiros (propuesto)

| Campo | Valor |
|---|---|
| Método | `POST` |
| Ruta | `/api/v1/transactions/withdrawals` |
| Descripción | Debitar fondos de una cuenta. |
| Permisos | Según rol (pendiente). |
| Headers | `Content-Type`, `X-Correlation-ID`, `Authorization`, `Idempotency-Key` |

**Request (ejemplo):**
```json
{
  "account_id": "uuid",
  "amount": "50.00",
  "currency": "USD",
  "description": "Retiro cajero"
}
```
**Errores:** `INSUFFICIENT_FUNDS`, `ACCOUNT_NOT_FOUND`, `ACCOUNT_INACTIVE`, `ACCOUNT_BLOCKED`, `VALIDATION_ERROR`, `IDEMPOTENCY_CONFLICT`, `UNAUTHORIZED`, `FORBIDDEN`.

## 8. Transferencias (propuesto)

| Campo | Valor |
|---|---|
| Método | `POST` |
| Ruta | `/api/v1/transactions/transfers` |
| Descripción | Transferir fondos entre cuentas (misma moneda o multimoneda según diseño). |
| Permisos | Según rol (pendiente). |
| Headers | `Content-Type`, `X-Correlation-ID`, `Authorization`, `Idempotency-Key` |

**Request (ejemplo):**
```json
{
  "source_account_id": "uuid",
  "target_account_id": "uuid",
  "amount": "25.00",
  "currency": "USD",
  "description": "Transferencia"
}
```
**Errores:** `INSUFFICIENT_FUNDS`, `ACCOUNT_NOT_FOUND`, `ACCOUNT_INACTIVE`, `ACCOUNT_BLOCKED`, `SAME_ACCOUNT_TRANSFER`, `CURRENCY_NOT_SUPPORTED`, `IDEMPOTENCY_CONFLICT`, `UNAUTHORIZED`, `FORBIDDEN`.

## 9. Preview de transferencias (propuesto)

| Campo | Valor |
|---|---|
| Método | `POST` |
| Ruta | `/api/v1/transactions/transfers/preview` |
| Descripción | Calcular conversión, comisión y montos resultantes sin ejecutar la transferencia. |
| Permisos | Según rol (pendiente). |
| Headers | `Content-Type`, `X-Correlation-ID`, `Authorization` |

**Request (ejemplo):** similar a transferencia, incluyendo moneda destino si aplica.  
**Response data (ejemplo):** `{ "exchange_rate": "1.10", "fee": "1.00", "debit_amount": "25.00", "credit_amount": "26.50" }`  
**Errores:** `VALIDATION_ERROR`, `EXCHANGE_RATE_NOT_FOUND`, `ACCOUNT_NOT_FOUND`, `UNAUTHORIZED`, `FORBIDDEN`.

> **Pendiente:** Definir modelo exacto de comisiones y conversión multimoneda.

## 10. Historial (propuesto)

| Método | Ruta | Descripción | Permisos |
|---|---|---|---|
| `GET` | `/api/v1/transactions` | Listar transacciones/historial del tenant (paginación y filtros pendientes) | Según rol |
| `GET` | `/api/v1/transactions/{id}` | Detalle de transacción y asientos | Según rol |
| `GET` | `/api/v1/accounts/{id}/transactions` | Historial por cuenta | Según rol |

**Headers:** `X-Correlation-ID`, `Authorization`  
**Errores:** `TRANSACTION_NOT_FOUND`, `ACCOUNT_NOT_FOUND`, `UNAUTHORIZED`, `FORBIDDEN`.

## 11. Configuración / Settings (propuesto)

| Método | Ruta | Descripción | Permisos |
|---|---|---|---|
| `GET` | `/api/v1/settings` | Obtener configuración del tenant autenticado | Según rol |
| `PUT` | `/api/v1/settings` | Actualizar configuración | Admin tenant (pendiente) |
| `GET` | `/api/v1/settings/exchange-rates` | Listar tasas de cambio | Según rol |
| `POST` | `/api/v1/settings/exchange-rates` | Registrar/actualizar tasa | Admin (pendiente) |

**Errores:** `VALIDATION_ERROR`, `SETTINGS_NOT_FOUND`, `UNAUTHORIZED`, `FORBIDDEN`.

## 12. Auditoría (propuesto)

| Método | Ruta | Descripción | Permisos |
|---|---|---|---|
| `GET` | `/api/v1/audit-logs` | Consultar registros de auditoría del tenant | Admin/auditor (pendiente) |
| `GET` | `/api/v1/audit-logs/{id}` | Detalle de registro | Admin/auditor |

**Errores:** `AUDIT_LOG_NOT_FOUND`, `UNAUTHORIZED`, `FORBIDDEN`.

## 13. Webhooks (propuesto)

| Método | Ruta | Descripción | Permisos |
|---|---|---|---|
| `POST` | `/api/v1/webhooks` | Registrar configuración de webhook | Admin tenant (pendiente) |
| `GET` | `/api/v1/webhooks` | Listar configuraciones | Admin tenant |
| `GET` | `/api/v1/webhooks/events` | Consultar eventos y estado de entrega | Admin tenant |

**Errores:** `VALIDATION_ERROR`, `WEBHOOK_NOT_FOUND`, `UNAUTHORIZED`, `FORBIDDEN`.

---

## Notas finales
- Las rutas, nombres de campos y códigos de error son **propuestas** y pueden ajustarse; deben mantenerse sincronizados con frontend y documentación.
- Definir paginación, filtrado, ordenamiento y límites de tasa (rate limiting) como parte del diseño detallado.
- Cualquier endpoint implementado debe reflejarse aquí con estado actualizado. 
