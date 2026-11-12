# Arquitectura del backend — BankOS

## Estado
- **Implementado (auditado):** No existe backend. El directorio `backend/` está vacío; no hay `pom.xml`, código Java, configuración Spring Boot, ni migraciones.
- **Decisión objetivo:** Monolito modular con Java 21 y Spring Boot 3.5.x, Maven, arquitectura por capas y módulos de dominio.

## Stack objetivo
- Java 21, Spring Boot 3.5.x, Maven
- Spring Web, Spring Security, Spring Data JPA, Hibernate
- Jakarta Bean Validation, Flyway
- JWT, Spring Data Redis
- PostgreSQL (driver) como BD principal

## Estructura modular objetivo (propuesta)

```text
backend/
└── src/main/java/.../bankos/
    ├── tenants/
    ├── authentication/
    ├── users/
    ├── customers/
    ├── accounts/
    ├── transactions/
    ├── idempotency/
    ├── settings/
    ├── audit/
    ├── webhooks/
    ├── common/            (propuesto: errores, seguridad, utilidades transversales)
    └── config/            (propuesto: seguridad, web, redis, jackson, etc.)
```

> La organización de paquetes exacta es **pendiente**; debe evitar dependencias circulares y respetar límites de módulo.

## Responsabilidades por módulo (objetivo)

| Módulo | Responsabilidad principal |
|---|---|
| `tenants` | Gestión de instituciones (tenants), datos y estado del tenant, base del aislamiento multitenant. |
| `authentication` | Login, emisión/validación de JWT, contexto de seguridad, cierre de sesión (según diseño). |
| `users` | Usuarios del sistema por tenant, roles/permisos y administración de accesos. |
| `customers` | Clientes finales de cada institución y sus datos asociados. |
| `accounts` | Cuentas bancarias, saldos, estados (activa/bloqueada/inactiva), monedas. |
| `transactions` | Depósitos, retiros, transferencias, preview de transferencias, historial y reglas financieras. |
| `idempotency` | Registro y verificación de `Idempotency-Key` para evitar ejecuciones duplicadas en operaciones financieras. |
| `settings` | Configuraciones por tenant (incl. tasas de cambio, parámetros operativos) según alcance definido. |
| `audit` | Registro de auditoría de acciones y eventos relevantes para trazabilidad. |
| `webhooks` | Configuración y emisión/registro de eventos hacia sistemas externos (entrega vía worker). |

## Separación por capas

| Capa | Responsabilidad | Reglas |
|---|---|---|
| **Controller** | Recibir solicitudes HTTP, validar entrada (Bean Validation), delegar a servicios, mapear respuestas DTO. | No contener reglas de negocio ni reglas financieras. No exponer entidades JPA. |
| **Service** | Implementar casos de uso y reglas de negocio/financieras, orquestar transacciones, coordinar repositorios y otros servicios. | Operaciones financieras con `@Transactional` y control de concurrencia según diseño. |
| **Repository** | Acceso a persistencia (Spring Data JPA), consultas filtradas por tenant. | No contener lógica de negocio; garantizar aislamiento por tenant en consultas. |
| **Entity** | Modelo de persistencia (JPA/Hibernate), mapeo a tablas PostgreSQL. | No exponerse directamente en la API. |
| **DTO** | Contratos de entrada/salida (request/response), desacoplamiento de la API respecto al modelo de datos. | Definir validaciones de entrada y formatos de respuesta. |

## Comunicación entre módulos y dependencias

- **Principio:** Dependencias unidireccionales y explícitas; **evitar dependencias circulares**.
- **Sugerencia (propuesta):** Módulos de dominio consumen capacidades transversales (`common/security`) y colaboran vía interfaces/servicios de aplicación bien definidos; `transactions` puede depender de `accounts`, `idempotency`, `audit` y `settings` según reglas, pero no al revés sin contratos claros.
- **Eventos internos:** Pendiente decidir si se usarán eventos de Spring para desacoplar auditoría/webhooks.
- **Pendiente:** Definir límites exactos y contratos internos entre módulos al iniciar implementación.

## Reglas transversales obligatorias (objetivo)

- `BigDecimal` para importes en Java; nunca `float`/`double`.
- Transacciones SQL para operaciones financieras; bloqueos de fila para concurrencia cuando aplique.
- No eliminar movimientos financieros; mantener trazabilidad mediante asientos/movimientos (`transaction_entries`).
- Validar `tenant` desde contexto autenticado; validar permisos en backend.
- No permitir operaciones sobre cuentas bloqueadas o inactivas.
- Respuestas y errores con `correlation_id` para trazabilidad.

## Configuración y migraciones (pendiente)

- **Flyway:** Migraciones versionadas en `backend/src/main/resources/db/migration` (propuesto). No existen migraciones actualmente.
- **Perfiles:** `dev/test/prod` (propuesto) con externalización de configuración vía variables de entorno.
- **Redis/JWT:** Parámetros y secretos deben inyectarse por entorno; no commitear credenciales.

## Pendientes técnicos inmediatos

1. Inicializar proyecto Maven (`pom.xml`) con Spring Boot 3.5.x y dependencias del stack.
2. Definir paquete base, estructura de módulos y configuración de seguridad (Spring Security + JWT).
3. Configurar conexión a PostgreSQL/Redis y Flyway.
4. Implementar manejo centralizado de excepciones y formato de respuesta estándar.
5. Establecer estrategia de resolución de tenant y filtros de autorización. 
