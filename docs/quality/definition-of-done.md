# Definition of Done — BankOS

> **Estado (2026-11-17):** aplicable al backend implementado. `mobile/` no se modificó.

## Backend

- [x] Compila con Java 21 / Maven.
- [x] `mvn -B test` pasa (3 unitarias + 4 de integración).
- [x] Migraciones Flyway aplican desde cero.
- [x] Docker Compose levanta API, PostgreSQL y Redis.
- [x] `/actuator/health` responde `UP`.
- [x] Login por institución y `/auth/me`.
- [x] Aislamiento entre tenants verificado.
- [x] Depósito, retiro, transferencia y preview.
- [x] Idempotencia con replay y conflicto.
- [x] Historial con filtros opcionales.
- [x] Auditoría persistida.
- [x] Outbox de webhooks.
- [x] Swagger/OpenAPI disponible.
- [x] Manejo de errores estandarizado.
- [x] README y documentación actualizados.
- [x] `mobile/` sin cambios.

## Pendiente para producción

- [ ] Refresh tokens y revocación.
- [ ] Rate limiting.
- [ ] RLS / cifrado por tenant.
- [ ] Pruebas de concurrencia, contrato y carga.
- [ ] CI/CD y Maven Wrapper.
- [ ] Observabilidad completa (métricas, trazas, alertas).
- [ ] Worker de webhooks separado.
- [ ] Conciliación contable.
- [ ] Integración con `mobile/`.

## Criterio de cierre

Una tarea backend está terminada cuando compila, pasa pruebas, respeta el aislamiento por tenant, documenta su contrato y no rompe `mobile/`.
