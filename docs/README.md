# BankOS — Documentación técnica y organizacional

> **Fuente única de verdad** para el equipo de desarrollo de BankOS.  
> Última auditoría del repositorio: **2026-11-12** (estado real del código reflejado en este documento).

## 1. ¿Qué es BankOS?

BankOS es una plataforma bancaria multitenant bajo el modelo **Banking as a Service (BaaS)**. Su objetivo es permitir que diferentes instituciones financieras operen independientemente dentro de una misma plataforma, manteniendo aislados sus usuarios, clientes, cuentas, configuraciones y operaciones financieras.

**Contexto:** proyecto desarrollado en una hackatón de 10 horas.

## 2. Estado actual del repositorio (auditado)

| Área | Estado observado | Detalle |
|---|---|---|
| Monorepo | **Parcial** | Existen directorios `backend/` y `mobile/` y `docs/`. |
| Backend (Java 21 / Spring Boot 3.5.x / Maven) | **No implementado** | El directorio `backend/` está vacío. No se encontraron `pom.xml`, código fuente, configuración Spring, ni migraciones Flyway. |
| Frontend (Flutter/Dart) | **Esqueleto inicial** | Proyecto Flutter creado por defecto (`mobile/lib/main.dart` con "Hello World"). No se han agregado dependencias requeridas (Riverpod, GoRouter, Dio, Flutter Secure Storage, Local Auth, UUID). SDK declarado: `^3.13.7`. |
| Base de datos (PostgreSQL) | **No configurada** | No hay migraciones, scripts ni configuración de conexión en el repositorio. |
| Cache/colas (Redis) | **No configurada** | No hay configuración ni integración en el repositorio. |
| Docker / Docker Compose | **No presente** | No se encontraron `Dockerfile` ni `docker-compose*.yml`. |
| Contratos de API | **No implementados** | No hay controladores, especificaciones OpenAPI/Swagger ni clientes HTTP configurados. |
| CI/CD / GitHub | **No presente** | No existe directorio `.github/` (se añade plantilla de PR como parte de esta documentación). No se verificaron protecciones de rama en GitHub. |
| Git | **Inicial** | Rama `master` sin commits al momento de la auditoría. No existe rama `develop`. |

> **Importante:** Este documento y los contenidos de `docs/` diferencian explícitamente entre **estado implementado (confirmado)**, **decisiones objetivo del proyecto** y **elementos pendientes/propuestos**. No se debe asumir que una funcionalidad existe solo porque está descrita como objetivo.

## 3. Stack tecnológico objetivo (obligatorio)

- **Frontend:** Dart, Flutter, Riverpod, GoRouter, Dio, Flutter Secure Storage, Local Auth, UUID.
- **Backend:** Java 21, Spring Boot 3.5.x, Maven, Spring Web, Spring Security, Spring Data JPA, Hibernate, Jakarta Bean Validation, Flyway, JWT, Spring Data Redis.
- **Infraestructura:** PostgreSQL, Redis, Docker, Docker Compose.
- **Arquitectura:** Backend monolito modular; Frontend feature-first; API REST JSON; monorepositorio.

## 4. Índice de documentación

### Arquitectura
- [Visión general de arquitectura](architecture/architecture-overview.md)
- [Arquitectura del backend](architecture/backend-architecture.md)
- [Arquitectura del frontend](architecture/frontend-architecture.md)
- [Diseño de base de datos](architecture/database-design.md)

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

## 5. Inconsistencias y hallazgos prioritarios (auditoría)

1. **Backend ausente:** `backend/` vacío; no hay base para módulos, API ni persistencia.
2. **Dependencias frontend no configuradas:** `pubspec.yaml` no incluye Riverpod, GoRouter, Dio, `flutter_secure_storage`, `local_auth`, `uuid` requeridos por el estándar.
3. **Navegación no conforme al objetivo:** `main.dart` usa `MaterialApp` directo sin GoRouter.
4. **Infraestructura ausente:** sin Docker Compose, PostgreSQL ni Redis definidos.
5. **Flujo Git no inicializado:** no hay commits, no existe `develop`, no hay protecciones verificables.
6. **Contratos/API y seguridad no implementados:** toda la definición funcional es pendiente/propuesta.

## 6. Recomendaciones prioritarias

1. Inicializar el backend Maven/Spring Boot en `backend/` con la estructura modular acordada y dependencias base.
2. Crear `docker-compose.yml` para PostgreSQL y Redis y definir `.env.example` (sin secretos reales).
3. Agregar dependencias Flutter obligatorias y establecer `core/router/app_router.dart` con GoRouter como única navegación.
4. Definir y versionar el contrato API inicial (`/api/v1`) antes de implementar pantallas y controladores en paralelo.
5. Inicializar Git con commit base, crear rama `develop` y configurar Branch Protection Rules en GitHub (PR obligatorio, 1 aprobación, sin autoaprobación, conversaciones resueltas).
6. Implementar primero el eje crítico: tenant + autenticación + contexto de seguridad + migraciones base, antes de operaciones financieras.
