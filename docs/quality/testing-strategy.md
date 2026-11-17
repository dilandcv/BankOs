# Estrategia de pruebas — BankOS

> **Estado (2026-11-17):** base implementada. La fuente canónica está en [`backend/docs/quality/testing-strategy.md`](../../backend/docs/quality/testing-strategy.md).

## Backend

| Tipo | Herramienta | Estado |
|---|---|---|
| Unitarias | JUnit 5, AssertJ | Implementado |
| Integración | Spring Boot Test, Testcontainers, PostgreSQL | Implementado |
| Seguridad | Login, JWT y aislamiento entre tenants | Implementado (base) |
| Concurrencia | Pruebas paralelas de idempotencia | Pendiente |
| Contrato | OpenAPI / cliente generado | Pendiente |
| Carga | k6 / Gatling / JMeter | Pendiente |

## Cobertura actual

- `MoneyUtilsTest`: redondeo y escalas.
- `TransactionApiIntegrationTest`: login, depósito, replay idempotente, conflicto de idempotencia, historial con filtros y aislamiento entre tenants.
- Total actual: **3 unitarias + 4 de integración**.

## Comando

```bash
docker run --rm \
  -v "$PWD/backend":/workspace \
  -v "$HOME/.m2":/root/.m2 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -w /workspace \
  maven:3.9-eclipse-temurin-21 \
  mvn -B test
```

## Frontend

`mobile/` no fue modificado. Sus pruebas actuales corresponden al prototipo con datos mock y no cubren integración con el backend.

## Pendiente

- Pruebas de concurrencia y transferencias simultáneas.
- Pruebas de contrato contra OpenAPI.
- Pruebas de carga y estrés.
- Pruebas de webhooks/outbox y reintentos.
- Pruebas end-to-end cuando se integre el frontend.
- Umbral de cobertura y análisis estático en CI.

## Documentación relacionada

- [Testing del backend](../../backend/docs/quality/testing-strategy.md)
- [Definition of Done](definition-of-done.md)
- [Criterios de aceptación](acceptance-criteria.md)
