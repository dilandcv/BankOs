# Seguridad financiera — BankOS

## Estado
- **Implementado (auditado):** No hay operaciones financieras implementadas.
- **Objetivo:** Garantizar integridad, consistencia, trazabilidad y protección ante duplicados/concurrencia en operaciones monetarias.

## Reglas obligatorias

- **Precisión monetaria:** `BigDecimal` en Java y `NUMERIC` en PostgreSQL. **Prohibido** `float`/`double`.
- **Inmutabilidad histórica:** No eliminar movimientos financieros; conservar `transactions`, `transaction_entries` y auditoría.
- **Atomicidad:** Operaciones financieras en transacciones SQL (`@Transactional`), con rollback ante fallos.
- **Concurrencia:** Proteger operaciones concurrentes mediante bloqueos de filas (ej. sobre cuentas afectadas) para evitar condiciones de carrera y saldos inconsistentes.
- **Trazabilidad:** Toda operación debe permitir reconstruir cambios de saldo a partir de movimientos contables (`transaction_entries`).
- **Idempotencia:** Operaciones financieras deben aceptar `Idempotency-Key` (UUID) y evitar ejecuciones duplicadas ante reintentos.
- **Validación de estado:** No permitir operaciones sobre cuentas bloqueadas o inactivas.
- **Autorización y tenant:** Validar permisos y pertenencia al tenant autenticado antes de ejecutar cualquier operación.

## Idempotencia
- El cliente genera `Idempotency-Key` por intención de operación y la conserva en reintentos junto con el **mismo cuerpo**.
- El backend registra la llave y el resultado asociado (alcance por tenant/operación, **diseño pendiente**) para devolver respuesta consistente ante duplicados.
- **Pendiente:** Definir almacenamiento (PostgreSQL/Redis), TTL, hash de request y semántica de conflicto.

## Auditoría
- Registrar eventos relevantes (quién, cuándo, tenant, acción, recurso, resultado, `correlation_id`).
- Los registros de auditoría deben ser persistentes y no modificables/eliminables como parte del flujo normal (política pendiente).

## Webhooks
- Emitir/despachar eventos **después de confirmar** la operación en base de datos.
- Manejar reintentos de entrega y estados de evento en el worker (propuesto).

## Reintentos seguros (cliente)
- Solo reintentar cuando sea seguro (timeouts/red) y la operación sea idempotente.
- Nunca cambiar `Idempotency-Key` ni el payload en un reintento de la misma operación financiera.

## Validaciones mínimas (propuesto)
- Montos positivos y en formato válido.
- Moneda soportada y coherente con la cuenta/operación.
- Saldo suficiente en retiros/transferencias.
- Cuentas origen/destino válidas, activas y autorizadas en el contexto del tenant.

## Pendientes
- Definir límites operativos, detección de fraude/anomalías y políticas de compensación (si aplican).
- Implementar y probar escenarios de concurrencia e idempotencia. 
