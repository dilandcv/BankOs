# Arquitectura del backend — BankOS

> **Estado (2026-11-17):** implementado. La fuente canónica y detallada está en [`backend/docs/architecture/architecture-overview.md`](../../backend/docs/architecture/architecture-overview.md).

## Stack

- Java 21, Spring Boot 3.5.x, Maven.
- Spring Web, Spring Security OAuth2 Resource Server (JWT Nimbus).
- Spring Data JPA / Hibernate, PostgreSQL 16, Flyway.
- Jakarta Bean Validation, Spring Data Redis, Actuator.
- springdoc OpenAPI / Swagger.
- Docker y Docker Compose.

## Estilo

Monolito modular con capas `controller → service → repository` y módulos de dominio bajo `com.bankos.modules`. Los componentes transversales viven en `com.bankos.common`.

```text
com.bankos
├── common/
│   ├── config/       # seguridad, OpenAPI, scheduling
│   ├── security/     # JWT, filtros, principal
│   ├── tenancy/      # TenantContext
│   ├── exception/    # ApiException, ErrorCode, handler
│   ├── response/     # ApiResponse, PageResponse
│   ├── money/        # MoneyUtils
│   └── web/          # correlation ID
└── modules/
    ├── auth/
    ├── tenants/
    ├── users/
    ├── customers/
    ├── accounts/
    ├── settings/
    ├── idempotency/
    ├── transactions/
    ├── audit/
    └── webhooks/
```

## Módulos

| Módulo | Responsabilidad |
|---|---|
| `auth` | Login por institución, emisión de JWT y `/auth/me`. |
| `tenants` | Instituciones, branding y estado. |
| `users` | Usuarios por tenant y roles. |
| `customers` | Clientes del tenant. |
| `accounts` | Cuentas, saldos y bloqueos. |
| `settings` | Configuración y tasas de cambio. |
| `idempotency` | Llaves, hash de request, replay y conflicto. |
| `transactions` | Depósitos, retiros, transferencias e historial. |
| `audit` | Registro de acciones. |
| `webhooks` | Configuración, outbox y dispatcher. |

## Reglas transversales

- `tenant_id` se obtiene del JWT; nunca del payload.
- Todas las consultas de negocio filtran por tenant.
- Dinero con `BigDecimal` y `NUMERIC(19,4)`.
- Operaciones financieras atómicas, idempotentes y auditadas.
- Sin eliminación física de movimientos financieros.
- Errores estandarizados con `correlation_id`.
- Configuración externalizada por variables de entorno.

## Persistencia y migraciones

- Flyway en `backend/src/main/resources/db/migration/` (`V1`–`V6`).
- Seed demo en `db/dev/V100__dev_seed.sql`, solo perfil `dev`.
- Hibernate `ddl-auto=validate`.
- Perfiles `dev`, `test`, `prod`.

## Documentación relacionada

- [Arquitectura del backend (detalle)](../../backend/docs/architecture/architecture-overview.md)
- [Diseño de base de datos](database-design.md)
- [Modelo multi-banco](multi-bank-model.md)
- [Autenticación](../security/authentication.md)
- [Multitenancy](../security/multitenancy.md)
- [API](../api/api-overview.md)
