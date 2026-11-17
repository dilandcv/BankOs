# Multitenancy — BankOS

> **Estado (2026-11-17):** implementado con aislamiento lógico. La fuente canónica está en [`backend/docs/security/multitenancy.md`](../../backend/docs/security/multitenancy.md).

## Modelo

- Cada institución es un tenant.
- Cada usuario pertenece a un solo tenant.
- `PLATFORM_ADMIN` pertenece al tenant reservado `PLATFORM`.
- Los datos de negocio llevan `tenant_id`.

## Fuente del tenant

El `tenant_id` se obtiene exclusivamente del JWT. **Nunca** se acepta del body, query params o headers del cliente.

`TenantContext` expone el tenant autenticado a servicios y repositorios.

## Aislamiento

- Repositorios y servicios filtran explícitamente por `tenant_id`.
- No hay RLS de PostgreSQL en el MVP.
- Un recurso de otro tenant responde `404` para no revelar su existencia.
- Las pruebas de integración cubren acceso cruzado entre `BANCO_HORIZONTE` y `NEQUI`.

## Datos por tenant

Instituciones, usuarios, clientes, cuentas, transacciones, configuración, tasas, auditoría y webhooks están acotados por tenant.

## Pendiente

- RLS de PostgreSQL.
- Cifrado por tenant.
- Prefijo de tenant en claves Redis.
- Auditoría de accesos cross-tenant a nivel de infraestructura.

## Documentación relacionada

- [Multitenancy del backend](../../backend/docs/security/multitenancy.md)
- [Autenticación](authentication.md)
- [Modelo multi-banco](../architecture/multi-bank-model.md)
