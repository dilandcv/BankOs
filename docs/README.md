# BankOS — Documentación técnica y organizacional

> **Fuente única de verdad** para el equipo de desarrollo de BankOS.
> **Última actualización:** 2026-11-17. El backend MVP ya está implementado y verificado; `mobile/` sigue siendo un prototipo con datos mock y **no fue modificado ni conectado** en esta fase.

## 1. ¿Qué es BankOS?

BankOS es una plataforma bancaria multitenant bajo el modelo **Banking as a Service (BaaS)**. Varias instituciones financieras operan dentro de una misma plataforma con datos, usuarios, cuentas y operaciones aislados por institución.

**Modelo de producto adoptado (Opción A):** una sola app con varios bancos; el usuario inicia sesión **una vez por banco** y la app guarda múltiples tokens para cambiar de institución. Ver [Modelo multi-banco](architecture/multi-bank-model.md).

**Contexto:** proyecto desarrollado en una hackatón de 10 horas.

## 2. Estado actual del repositorio

| Área | Estado | Detalle |
|---|---|---|
| Monorepo | **Implementado** | `backend/`, `mobile/` y `docs/`. |
| Backend (Java 21 / Spring Boot 3.5.x / Maven) | **Implementado (MVP)** | API REST `/api/v1`, seguridad JWT, multitenancy, PostgreSQL/Flyway, Redis configurado, idempotencia, auditoría y webhooks/outbox. |
| Frontend (Flutter/Dart) | **Prototipo con datos mock** | Tiene UI, Riverpod y GoRouter, pero usa datos mock de un solo banco. No tiene cliente HTTP ni almacenamiento de tokens. **No consume el backend** y no se modificó en esta fase. |
| Base de datos (PostgreSQL) | **Implementada** | Migraciones Flyway `V1`–`V6` y seed de desarrollo `V100`. |
| Cache/colas (Redis) | **Configurada** | Dependencia y conexión listas; PostgreSQL es la fuente de verdad. |
| Docker / Docker Compose | **Implementado** | `backend/Dockerfile` y `backend/docker-compose.yml` con PostgreSQL, Redis y healthchecks. |
| Contratos de API | **Implementados (MVP)** | Controladores, DTOs, manejo de errores y OpenAPI/Swagger. |
| Pruebas | **Implementado (base)** | 3 unitarias + 4 de integración con Testcontainers: login, depósito, idempotencia, historial y aislamiento. |
| CI/CD / GitHub | **Pendiente** | No hay workflows de GitHub Actions en el repositorio. |
| Git | **Activo** | Rama `feature/backend-implementation` para esta fase. |

> **Importante:** la documentación diferencia entre lo implementado, lo propuesto y lo pendiente. No se debe asumir que una funcionalidad del frontend existe solo porque esté descrita como objetivo.

## 3. Stack tecnológico

- **Frontend actual:** Dart, Flutter, Riverpod y GoRouter (prototipo mock, sin integración).
- **Frontend objetivo:** agregar Dio, Flutter Secure Storage, Local Auth y UUID para el modelo multi-banco.
- **Backend:** Java 21, Spring Boot 3.5.x, Maven, Spring Web, Spring Security, OAuth2 Resource Server (JWT Nimbus), Spring Data JPA, Hibernate, Jakarta Bean Validation, Flyway, Spring Data Redis, springdoc OpenAPI.
- **Infraestructura:** PostgreSQL 16, Redis 7, Docker, Docker Compose.
- **Arquitectura:** backend monolito modular; frontend feature-first; API REST JSON; monorepositorio.

## 4. Índice de documentación

### Producto y arquitectura
- [Modelo multi-banco (Opción A)](architecture/multi-bank-model.md)
- [Visión general de arquitectura](architecture/architecture-overview.md)
- [Arquitectura del backend](architecture/backend-architecture.md)
- [Arquitectura del frontend](architecture/frontend-architecture.md)
- [Diseño de base de datos](architecture/database-design.md)

### Backend
- [Documentación del backend](../backend/docs/README.md)
- [Plan de implementación del backend](../backend/docs/implementation-plan.md)
- [API overview](../backend/docs/api/api-overview.md)
- [Contratos de API](../backend/docs/api/api-contracts.md)
- [Autenticación](../backend/docs/security/authentication.md)
- [Multitenancy](../backend/docs/security/multitenancy.md)
- [Seguridad financiera](../backend/docs/security/financial-security.md)

### Desarrollo
- [Guía de inicio (Getting Started)](development/getting-started.md)
- [Estándares de codificación](development/coding-standards.md)
- [Flujo de trabajo Git](development/git-workflow.md)
- [Proceso de Pull Requests](development/pull-request-process.md)
- [Organización del equipo](development/team-organization.md)

### API
- [Visión general de la API](api/api-overview.md)
- [Contratos de API](api/api-contracts.md)
- [Manejo de errores](api/error-handling.md)

### Seguridad
- [Autenticación](security/authentication.md)
- [Multitenancy](security/multitenancy.md)
- [Seguridad financiera](security/financial-security.md)

### Calidad
- [Estrategia de pruebas](quality/testing-strategy.md)
- [Definition of Done](quality/definition-of-done.md)
- [Criterios de aceptación](quality/acceptance-criteria.md)

## 5. Ejecución del backend

```bash
cd backend
cp .env.example .env
docker compose up --build
```

> Si el puerto `5432` está ocupado, ejecuta `DB_PORT=55432 docker compose up --build`.

- API: `http://localhost:8080`
- Swagger UI (perfil `dev`): `http://localhost:8080/swagger-ui.html`
- Health: `http://localhost:8080/actuator/health`
- Credenciales demo: ver [backend/README.md](../backend/README.md).

## 6. Límites y siguientes pasos

1. **Frontend multi-banco:** selector de banco, login por institución, tema dinámico, almacenamiento seguro multi-token y cliente Dio.
2. **Integración frontend-backend:** reemplazar mocks por repositorios reales, manteniendo el backend ejecutable de forma independiente.
3. **Sesiones:** refresh tokens, revocación y rotación.
4. **Seguridad de producción:** secretos gestionados, TLS, rate limiting y RLS opcional.
5. **Operación:** worker de webhooks separado, métricas, trazas y CI/CD.
6. **Contabilidad:** evaluar doble partida estricta con cuentas de sistema para comisiones.
