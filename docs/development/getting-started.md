# Guía de inicio — BankOS

> **Estado (2026-11-17):** el backend está implementado y se ejecuta con Docker Compose. `mobile/` no fue modificado ni conectado.

## Requisitos

- Docker y Docker Compose.
- Opcional: Java 21 + Maven 3.9 para ejecutar sin Docker.
- `curl` o Swagger para probar la API.

## Ejecución

```bash
cd backend
cp .env.example .env
docker compose up --build
```

> Si el puerto `5432` está ocupado, usa `DB_PORT=55432 docker compose up --build`.

Servicios:

- API: `http://localhost:8080`
- Swagger UI: `http://localhost:8080/swagger-ui.html`
- OpenAPI: `http://localhost:8080/v3/api-docs`
- Health: `http://localhost:8080/actuator/health`

El perfil `dev` carga instituciones, usuarios, clientes, cuentas, configuración y tasas demo.

## Credenciales demo

Contraseña para todos los usuarios demo: `Admin123!`

| Institución | `tenant_code` | Email |
|---|---|---|
| BankOS Platform | `PLATFORM` | `platform@bankos.com` |
| Nequi | `NEQUI` | `admin@nequi.com` |
| Daviplata | `DAVIPLATA` | `admin@daviplata.com` |
| PayPal | `PAYPAL` | `admin@paypal.com` |
| Bancolombia | `BANCOLOMBIA` | `admin@bancolombia.com` |
| NU | `NU` | `admin@nu.com` |
| Banco Horizonte | `BANCO_HORIZONTE` | `admin@horizonte.com` |

También existen usuarios `operador@*` y `auditor@*` en Horizonte y Nequi.

## Login

```bash
TOKEN=$(curl -s http://localhost:8080/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"tenant_code":"BANCO_HORIZONTE","email":"admin@horizonte.com","password":"Admin123!"}' \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["data"]["access_token"])')
```

## Depósito idempotente

```bash
curl -s http://localhost:8080/api/v1/transactions/deposits \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: demo-deposit-001' \
  -d '{
    "account_id":"30000000-0000-0000-0000-000000000001",
    "amount":"100.00",
    "currency":"USD",
    "description":"Depósito demo"
  }'
```

## Build y pruebas sin Compose

```bash
cd backend

docker run --rm -v "$PWD":/workspace -v "$HOME/.m2":/root/.m2 \
  -w /workspace maven:3.9-eclipse-temurin-21 \
  mvn -B -DskipTests package

docker run --rm -v "$PWD":/workspace -v "$HOME/.m2":/root/.m2 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -w /workspace maven:3.9-eclipse-temurin-21 \
  mvn -B test
```

Los tests de integración usan Testcontainers y requieren Docker accesible.

## Documentación relacionada

- [Guía detallada del backend](../../backend/docs/development/getting-started.md)
- [README del backend](../../backend/README.md)
- [Modelo multi-banco](../architecture/multi-bank-model.md)
- [API](../api/api-overview.md)
