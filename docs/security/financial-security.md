# Seguridad financiera — BankOS

> **Estado (2026-11-17):** implementada en el backend. La fuente canónica está en [`backend/docs/security/financial-security.md`](../../backend/docs/security/financial-security.md).

## Dinero

- `BigDecimal` en Java; `NUMERIC(19,4)` en PostgreSQL.
- Tasas `NUMERIC(19,8)`.
- Escala 4 y `RoundingMode.HALF_UP`.
- Prohibido `float`/`double` para importes.

## Atomicidad y concurrencia

- Operaciones financieras dentro de transacciones SQL.
- Bloqueo pesimista (`PESSIMISTIC_WRITE`) de las cuentas afectadas.
- Transferencias bloquean cuentas en orden determinista para evitar deadlocks.
- `CHECK (balance >= 0)` y validación de saldo; sin sobregiro en el MVP.

## Idempotencia

- `Idempotency-Key` obligatorio en depósitos, retiros y transferencias.
- Clave única `(tenant_id, operation, idempotency_key)`.
- Hash del cuerpo y snapshot de respuesta.
- Advisory lock de PostgreSQL para concurrencia.
- Mismo cuerpo → replay; cuerpo distinto → `409 IDEMPOTENCY_CONFLICT`.

## Registro contable

- Cada operación crea una transacción y sus movimientos en `transaction_entries`.
- No se eliminan físicamente movimientos financieros.
- El saldo debe poder reconstruirse desde los movimientos.

## Auditoría

- `audit_logs` registra actor, tenant, acción, entidad, datos y correlation ID.
- La auditoría se escribe en la misma transacción de negocio.

## Webhooks

- Patrón outbox en PostgreSQL.
- El dispatcher envía después del commit.
- Fallos de webhooks no revierten la operación financiera.
- Reintentos controlados por configuración.

## Pendiente

- Conciliación contable y cierre diario.
- Doble partida estricta con cuentas de sistema para comisiones.
- Alertas de saldos y detección de anomalías.
- Pruebas de concurrencia y carga.

## Documentación relacionada

- [Seguridad financiera del backend](../../backend/docs/security/financial-security.md)
- [Idempotencia](../api/api-contracts.md#idempotencia)
- [Diseño de base de datos](../architecture/database-design.md)
