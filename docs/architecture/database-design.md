# Diseño de base de datos — BankOS

> **Estado (2026-11-17):** implementado con PostgreSQL 16 y Flyway. La fuente canónica está en [`backend/docs/architecture/database-design.md`](../../backend/docs/architecture/database-design.md).

## Principios

- PostgreSQL es la fuente de verdad.
- Esquema versionado exclusivamente con Flyway.
- `tenant_id` obligatorio en datos de negocio.
- Integridad referencial, `NOT NULL`, `UNIQUE`, `CHECK` e índices.
- Sin borrado físico de movimientos financieros.

## Tipos monetarios

| Dato | Tipo | Escala |
|---|---|---|
| Saldos e importes | `NUMERIC(19,4)` | 4 |
| Tasas de cambio | `NUMERIC(19,8)` | 8 |
| Comisiones | `NUMERIC(19,4)` | 4 |

En Java se usa `BigDecimal` con escala 4 y `RoundingMode.HALF_UP`.

## Tablas principales

| Tabla | Propósito |
|---|---|
| `tenants` | Instituciones, branding y estado. |
| `users` | Usuarios por tenant y rol. |
| `customers` | Clientes del tenant. |
| `accounts` | Cuentas y saldos. |
| `transactions` | Cabecera de operaciones financieras. |
| `transaction_entries` | Movimientos contables por cuenta. |
| `idempotency_records` | Llaves, hash y snapshot de respuesta. |
| `audit_logs` | Auditoría de acciones. |
| `tenant_settings` | Configuración por tenant. |
| `exchange_rates` | Tasas por par de monedas. |
| `webhook_endpoints` | Destinos de webhooks. |
| `webhook_events` | Outbox de eventos. |

## Restricciones clave

- Usuarios con `tenant_id` obligatorio.
- `PLATFORM_ADMIN` en el tenant reservado `PLATFORM`.
- `CHECK (balance >= 0)` en cuentas.
- Idempotencia única por `(tenant_id, operation, idempotency_key)`.
- Índices por `tenant_id`, cuentas, fechas y estado de outbox.
- Transferencias ordenan las cuentas antes de bloquearlas para evitar deadlocks.

## Migraciones

```text
backend/src/main/resources/db/
├── migration/
│   ├── V1__...
│   ├── V2__...
│   ├── V3__...
│   ├── V4__...
│   ├── V5__...
│   └── V6__...
└── dev/
    └── V100__dev_seed.sql
```

El seed crea las instituciones `PLATFORM`, `NEQUI`, `DAVIPLATA`, `PAYPAL`, `BANCOLOMBIA`, `NU` y `BANCO_HORIZONTE`, con usuarios, clientes, cuentas, settings y tasas demo.

## RLS y particionamiento

No se implementaron en el MVP. El aislamiento es lógico y explícito en repositorios/servicios. RLS queda en el backlog.

## Documentación relacionada

- [Diseño de BD del backend](../../backend/docs/architecture/database-design.md)
- [Multitenancy](../security/multitenancy.md)
- [Seguridad financiera](../security/financial-security.md)
