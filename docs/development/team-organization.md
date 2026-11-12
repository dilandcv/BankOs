# Organización del equipo — BankOS

## Equipo
El equipo está compuesto por **4 integrantes**. No se inventan nombres en esta documentación; se identifican por rol/responsabilidad inicial.

## Distribución inicial propuesta

| Integrante | Responsabilidad principal |
|---|---|
| **Integrante 1** | Backend: `tenants`, `authentication`, `users` y seguridad |
| **Integrante 2** | Backend: `accounts`, `transactions` y multimoneda |
| **Integrante 3** | Infraestructura, PostgreSQL, Redis, `idempotency`, `audit` y `webhooks` |
| **Integrante 4** | Frontend: Flutter, Riverpod, GoRouter, autenticación, dashboard, cuentas, operaciones e historial |

> Esta distribución es una **propuesta inicial** y puede ajustarse según avance y disponibilidad.

## Reglas de colaboración
- Todos los integrantes pueden (y deben, según disponibilidad) participar en **revisiones de Pull Requests**.
- Los integrantes deben **coordinar los contratos de API** antes y durante la implementación para evitar bloqueos e incompatibilidades.
- Cada responsable backend implementa los **modelos y repositorios de su módulo**, respetando límites y evitando dependencias circulares.
- **Infraestructura no debe convertirse en el único responsable de todas las consultas SQL**; el conocimiento y ownership de datos se comparte según módulo.
- Los módulos deben **integrarse progresivamente** en `develop` mediante PRs pequeños y revisados.

## Dependencias entre integrantes (propuestas)

| Dependencia | Descripción | Impacto |
|---|---|---|
| Integrante 1 → 2,3,4 | Definir tenant, autenticación, JWT, contexto de seguridad y modelo de usuarios/roles | Base para autorización, aislamiento multitenant y acceso desde frontend |
| Integrante 3 → 1,2 | Proveer Docker Compose, PostgreSQL/Redis, migraciones base y lineamientos de idempotencia/auditoría/webhooks | Entorno reproducible y capacidades transversales para operaciones |
| Integrante 2 → 4 | Contratos de cuentas/transacciones (depósitos, retiros, transferencias, preview, historial) y reglas de estado/errores | Implementación de pantallas y flujos financieros en Flutter |
| Integrante 4 → 1,2 | Requerimientos de UX, formatos de respuesta/errores necesarios para UI y manejo de sesión/expiración | Ajustes de API y consistencia de experiencia |
| Todos ↔ Todos | Alineación de `X-Correlation-ID`, `Idempotency-Key`, códigos de error y versionado `/api/v1` | Trazabilidad, reintentos seguros e integración sin fricción |

## Entregas esperadas (orientativas por área)

### Integrante 1 — Seguridad y núcleo de acceso
- Estructura base backend (Maven/Spring Boot), configuración de seguridad.
- Módulos/funcionalidad de `tenants`, `authentication`, `users`.
- Emisión/validación JWT y extracción de tenant desde contexto autenticado.
- Documentación de endpoints y roles asociados.

### Integrante 2 — Dominio financiero
- Módulos/funcionalidad de `accounts` y `transactions` (incl. multimoneda según alcance).
- Reglas de negocio financieras, validaciones de estado de cuenta y consistencia transaccional.
- Integración con idempotencia/auditoría según contratos internos.
- Documentación de contratos de operaciones y errores.

### Integrante 3 — Plataforma e infraestructura
- `docker-compose.yml`, `.env.example` (sin secretos) y guía de ejecución local.
- PostgreSQL/Redis operativos, estrategia de migraciones Flyway y soporte a `idempotency`, `audit`, `webhooks`.
- Worker de webhooks (si aplica) y consideraciones de healthchecks/redes/volúmenes.
- Apoyo en observabilidad básica y resolución de incidencias de entorno.

### Integrante 4 — Frontend móvil
- Estructura feature-first en `mobile/`, configuración de Riverpod y GoRouter (`core/router/app_router.dart`).
- Cliente Dio con interceptores (JWT, `X-Correlation-ID`, `Idempotency-Key`) y manejo centralizado de errores.
- Almacenamiento seguro de sesión (Flutter Secure Storage) y flujos de autenticación/navegación protegida.
- Pantallas/flujos: login, dashboard, cuentas, operaciones, historial y perfil (según alcance).

## Coordinación recomendada
- Definir contrato API mínimo compartido al inicio (autenticación, formato de respuesta/error, headers).
- Sincronizaciones cortas para resolver bloqueos de integración.
- Actualizar documentación en `docs/` cuando se tomen decisiones o cambien contratos.

## Pendientes
- Asignación nominal de integrantes a los roles propuestos.
- Acuerdo sobre estrategia de merge, versionado y calendario de integración para la hackatón. 
