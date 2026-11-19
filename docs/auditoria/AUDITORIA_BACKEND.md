# AUDITORÍA TÉCNICA Y FUNCIONAL DEL BACKEND (SPRING BOOT)

**Fecha:** 2026-11-18  
**Componente:** `backend/`  
**Tecnología:** Java 21 / Spring Boot 3.5.0 / Maven / PostgreSQL 16 / Redis 7  
**Estado General:** Monolito modular de producción verificado. Lógica de negocio real, persistencia en base de datos, idempotencia transaccional y seguridad JWT Nimbus implementadas al 100%. Cero datos mock en runtime.  

---

## 1. Arquitectura del Monolito Modular

El backend está estructurado bajo un patrón de **monolito modular** en capas por dominio, siguiendo principios de alta cohesión y bajo acoplamiento:

```text
backend/src/main/java/com/bankos/
├── BankOsApplication.java                  # Entrypoint Spring Boot
├── common/                                 # Capacidades transversales
│   ├── config/                             # OpenApiConfig, JacksonConfig, HttpClientConfig
│   ├── exception/                          # ApiException, ErrorCode, GlobalExceptionHandler
│   ├── money/                              # MoneyUtils (redondeo a 4 decimales Half-Up, validación de divisas)
│   ├── persistence/                        # BaseEntity (UUID, auditoría temporal), TenantScopedEntity
│   ├── response/                           # ApiResponse (envelope estándar), PageResponse
│   ├── security/                           # SecurityConfig, JwtService, JwtConfig, EntryPoints, Handlers
│   ├── tenancy/                            # TenantContext, TenantContextFilter (extracción de JWT)
│   └── web/                                # CorrelationIdFilter, CorrelationIdContext
└── modules/
    ├── accounts/                           # Cuentas bancarias (balances, numeración, bloqueo)
    ├── audit/                              # Auditoría de operaciones (JSONB persistente)
    ├── auth/                               # Login multi-tenant, emisión de tokens, /me
    ├── customers/                          # Gestión de clientes bancarios
    ├── idempotency/                        # Deduplicación y replay de transacciones financieras
    ├── settings/                           # Tasas de cambio y comisiones por institución
    ├── tenants/                            # Instituciones bancarias participantes
    ├── transactions/                       # Depósitos, retiros, transferencias y doble partida
    ├── users/                              # Operadores, administradores y auditores del banco
    └── webhooks/                           # Outbox pattern para eventos asíncronos y firmas HMAC
```

---

## 2. Inspección por Capas y Componentes

### 2.1 Controladores REST (`@RestController`)
Existen **9 controladores REST** bajo el prefijo unificado `/api/v1` con un total de **31 métodos de endpoint**:

| Controlador | Mapeo Base | Endpoints Expuestos | Roles Requeridos |
|---|---|---|---|
| `AuthController` | `/api/v1/auth` | `POST /login`<br>`GET /me` | Público<br>Autenticado |
| `TenantController` | `/api/v1/tenants` | `POST /`<br>`GET /`<br>`GET /{id}` | `PLATFORM_ADMIN`<br>`PLATFORM_ADMIN`, `TENANT_ADMIN`<br>`PLATFORM_ADMIN`, `TENANT_ADMIN` |
| `UserController` | `/api/v1/users` | `POST /`<br>`GET /`<br>`GET /{id}` | `PLATFORM_ADMIN`, `TENANT_ADMIN` |
| `CustomerController` | `/api/v1/customers` | `POST /`<br>`GET /`<br>`GET /{id}` | `TENANT_ADMIN`, `OPERATOR`<br>Todos los roles autenticados<br>Todos los roles autenticados |
| `AccountController` | `/api/v1/accounts` | `POST /`<br>`GET /`<br>`GET /all`<br>`GET /{id}` | `TENANT_ADMIN`, `OPERATOR`<br>Todos los roles autenticados<br>Todos los roles autenticados<br>Todos los roles autenticados |
| `TransactionController` | `/api/v1/transactions` | `POST /deposits`<br>`POST /withdrawals`<br>`POST /transfers`<br>`POST /transfers/preview`<br>`GET /`<br>`GET /{id}` | `TENANT_ADMIN`, `OPERATOR` (Idempotente)<br>`TENANT_ADMIN`, `OPERATOR` (Idempotente)<br>`TENANT_ADMIN`, `OPERATOR` (Idempotente)<br>Todos los roles autenticados<br>Todos los roles autenticados<br>Todos los roles autenticados |
| `SettingsController` | `/api/v1/settings` | `GET /`<br>`PUT /`<br>`GET /exchange-rates`<br>`GET /exchange-rates/{id}`<br>`POST /exchange-rates` | Todos los roles autenticados<br>`TENANT_ADMIN`, `PLATFORM_ADMIN`<br>Todos los roles autenticados<br>Todos los roles autenticados<br>`TENANT_ADMIN`, `PLATFORM_ADMIN` |
| `AuditController` | `/api/v1/audit-logs` | `GET /`<br>`GET /{id}` | `PLATFORM_ADMIN`, `TENANT_ADMIN`, `AUDITOR` |
| `WebhookController` | `/api/v1/webhooks` | `GET /`<br>`POST /`<br>`GET /events` | `PLATFORM_ADMIN`, `TENANT_ADMIN`, `AUDITOR`<br>`PLATFORM_ADMIN`, `TENANT_ADMIN`<br>`PLATFORM_ADMIN`, `TENANT_ADMIN`, `AUDITOR` |

### 2.2 Servicios de Negocio (`@Service`)
- **Ausencia total de datos simulados:** Ningún servicio utiliza listas estáticas, mocks en runtime ni datos inventados.
- **`AuthService`:** Resuelve tenants activos, busca el usuario por tenant y correo, verifica el hash de contraseña con BCrypt, emite JWT mediante Nimbus y registra auditoría.
- **`AccountService`:** Valida que el cliente pertenezca al tenant del token, normaliza divisas ISO-4217, genera número de cuenta aleatorio seguro y persiste con saldo inicial cero.
- **`TransactionService`:**
  - Aplica control de **idempotencia estricto** en depósitos, retiros y transferencias mediante la cabecera `Idempotency-Key`.
  - En transferencias, previene interbloqueos (*deadlocks*) ordenando determinísticamente los UUIDs de las cuentas antes de bloquearlas pesimísticamente en la base de datos (`lockAccountsInOrder`).
  - Resuelve dinámicamente tasas de cambio y comisiones (fijas y porcentuales) configuradas por institución.
  - Implementa **doble partida contable** en la tabla `transaction_entries` (registro de Débito y Crédito auditados).
  - Emite eventos al outbox de webhooks de manera transaccional.
- **`IdempotencyService`:** Calcula hash SHA-256 del cuerpo de la petición. Si la misma llave se reutiliza con un cuerpo diferente, genera `409 IDEMPOTENCY_CONFLICT`. Si el cuerpo coincide, devuelve el snapshot original de la respuesta (`replayPayload`).

### 2.3 Persistencia y Repositorios (`@Repository`)
- Todos los repositorios extienden `JpaRepository` y están respaldados por PostgreSQL real.
- **Aislamiento Multitenant:** Todas las consultas derivan o filtran explícitamente por `tenantId` (ej. `findByTenantIdAndEmail`, `findByIdAndTenantId`, `findAllByTenantId`). No es posible para un usuario de un banco consultar o alterar entidades de otra institución.
- Restricciones de integridad referencial a nivel de base de datos con `ON DELETE RESTRICT`.

### 2.4 Seguridad y Autorización
- **Spring Security 6 + OAuth2 Resource Server:** Integración sin estado (`SessionCreationPolicy.STATELESS`).
- **Validación de JWT:** Se extrae `tenant_id`, `sub` (user ID), `email` y la lista de `roles`.
- **Filtro de contexto:** `TenantContextFilter` inyecta un objeto inmutable `TenantContext.Principal` en un `ThreadLocal` y garantiza su limpieza en el bloque `finally`.
- **RBAC:** Roles jerárquicos evaluados con `@PreAuthorize("hasAnyRole(...)")`.
- **Contraseñas:** Hash con `BCryptPasswordEncoder(12)`.
- **CORS:** Configurado mediante patrones de origen permitidos (`CORS_ALLOWED_ORIGINS`).

### 2.5 Manejo de Errores y Validaciones
- **Envelope uniforme:** Todas las respuestas (éxito y error) siguen la estructura:
  ```json
  {
    "success": false,
    "code": "ERROR_CODE",
    "message": "Mensaje legible",
    "data": null,
    "correlation_id": "uuid"
  }
  ```
- **`GlobalExceptionHandler`:** Captura `ApiException`, `MethodArgumentNotValidException`, `ConstraintViolationException`, `MissingRequestHeaderException` (para cabecera `Idempotency-Key`), `DataIntegrityViolationException` y fallos no controlados (`500 INTERNAL_ERROR`) sin exponer stacktraces en producción.
- **Correlación:** `CorrelationIdFilter` propaga o genera un UUID en la cabecera `X-Correlation-ID` y en los logs de MDC.

### 2.6 Integración con Redis
- Conexión configurada en `application.yml` y healthcheck habilitado en Actuator.
- **Hallazgo técnico:** El código actual no utiliza Redis para almacenamiento en caché de entidades ni rate limiting. Todas las operaciones de consulta y persistencia van directamente a PostgreSQL.

### 2.7 Pruebas Automatizadas
- **Pruebas Unitarias:** `MoneyUtilsTest` (3 tests verificados con JUnit 5).
- **Pruebas de Integración:** `TransactionApiIntegrationTest` (4 tests verificados con Testcontainers y PostgreSQL 16 real).
  - Tasa de aprobación: **100% (7/7 tests exitosos)**.

---

## 3. Matriz de Clasificación de Módulos del Backend

| Módulo | Entidades Persistentes | Lógica de Negocio Real | Usa Mocks en Runtime | Pruebas Automatizadas | Estado |
|---|:---:|:---:|:---:|:---:|---|
| `auth` | `Tenant`, `User` | SÍ | NO | SÍ (Integration test) | **IMPLEMENTADA** |
| `tenants` | `Tenant` | SÍ | NO | SÍ (Integration test) | **IMPLEMENTADA** |
| `users` | `User` | SÍ | NO | SÍ (Integration test) | **IMPLEMENTADA** |
| `customers` | `Customer` | SÍ | NO | SÍ (Integration test) | **IMPLEMENTADA** |
| `accounts` | `Account` | SÍ | NO | SÍ (Integration test) | **IMPLEMENTADA** |
| `transactions` | `Transaction`, `TransactionEntry` | SÍ | NO | SÍ (Integration test) | **IMPLEMENTADA** |
| `settings` | `TenantSetting`, `ExchangeRate` | SÍ | NO | Parcial | **IMPLEMENTADA** |
| `idempotency` | `IdempotencyRecord` | SÍ | NO | SÍ (Integration test) | **IMPLEMENTADA** |
| `audit` | `AuditLog` | SÍ | NO | Parcial | **IMPLEMENTADA** |
| `webhooks` | `WebhookConfig`, `OutboxEvent` | SÍ | NO | Parcial | **IMPLEMENTADA** |

---

## 4. Problemas Técnicos y Recomendaciones del Backend

1. **Redis no aprovechado:** Se incluye la infraestructura y dependencias de Redis, pero no se utiliza en capa de negocio. Se recomienda implementar caché de tasas de cambio y rate limiting.
2. **Warn en Pool Hikari durante Tests:** El scheduler de `OutboxDispatcher` intenta validar conexiones a la base de datos mientras el contexto de Testcontainers se apaga, generando alertas en logs (`Failed to validate connection ... connection closed`). Se recomienda deshabilitar el scheduler en el perfil de test (`spring.task.scheduling.enabled: false`, ya presente en `application-test.yml`, pero `OutboxDispatcher` usa `@Scheduled` nativo).
3. **Ausencia de exportación física de OpenAPI:** El backend genera la API dinámicamente pero no la guarda en un archivo `openapi.yaml` versionado.
