# Criterios de aceptación — BankOS

> **Estado (2026-11-17):** criterios del backend MVP implementado. `mobile/` no fue modificado.

## Autenticación

- [x] Login con `tenant_code + email + password`.
- [x] Token JWT con `tenant_id` y roles.
- [x] `/auth/me` devuelve usuario y tenant.
- [x] Credenciales inválidas responden `401`.
- [x] Token de otra institución no accede a recursos ajenos.

## Multitenancy

- [x] Todo dato de negocio está acotado por tenant.
- [x] El tenant se toma del JWT.
- [x] Acceso cruzado responde `404`.
- [x] Seed con múltiples instituciones.

## Operaciones financieras

- [x] Depósito, retiro y transferencia.
- [x] Preview de transferencia con tasa y comisión.
- [x] Saldo insuficiente rechazado.
- [x] Moneda incorrecta rechazada.
- [x] Sin sobregiro.
- [x] Importes con `BigDecimal`.
- [x] Bloqueo pesimista y orden determinista.
- [x] Movimientos contables persistidos.

## Idempotencia

- [x] `Idempotency-Key` obligatorio.
- [x] Misma llave y cuerpo → misma respuesta.
- [x] Misma llave y cuerpo distinto → `409`.
- [x] Concurrencia serializada con advisory lock.

## Historial y auditoría

- [x] Historial paginado.
- [x] Filtros opcionales por cuenta, tipo y fechas.
- [x] Orden por fecha descendente.
- [x] Auditoría por tenant.
- [x] Outbox de webhooks.

## API

- [x] Respuestas con `success/code/message/data/correlation_id`.
- [x] JSON `snake_case`.
- [x] OpenAPI y Swagger.
- [x] Health con PostgreSQL y Redis.

## Pendiente de aceptación

- [ ] Refresh tokens y logout global.
- [ ] Rate limiting.
- [ ] RLS.
- [ ] Pruebas de carga y concurrencia.
- [ ] Integración con `mobile/`.
- [ ] CI/CD.

## Evidencia

- `backend/src/test/java/com/bankos/integration/TransactionApiIntegrationTest.java`
- `backend/src/test/java/com/bankos/common/money/MoneyUtilsTest.java`
- [Testing](testing-strategy.md)
- [Definition of Done](definition-of-done.md)
