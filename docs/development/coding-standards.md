# Estándares de codificación — BankOS

## Principios generales
- Mantener consistencia con la estructura, nombres y patrones existentes del repositorio.
- Cambios pequeños, revisables y alineados a la arquitectura definida.
- No introducir lógica financiera en controllers ni en Flutter.
- No commitear secretos, credenciales ni tokens.

## Java (Backend)

### Estructura y responsabilidades
- Clases con responsabilidades claras y cohesivas.
- Nombres descriptivos (clases, métodos, variables, paquetes).
- Separación estricta por capas:
  - **Controller:** entrada/salida HTTP, validación, delegación.
  - **Service:** reglas de negocio y financieras, orquestación, transacciones.
  - **Repository:** persistencia y consultas.
  - **Entity:** modelo de BD (JPA).
  - **DTO:** contratos de API (request/response).
- No exponer entidades JPA directamente en la API.
- No colocar reglas de negocio/financieras en controllers.

### Validación y errores
- Validar entradas con **Jakarta Bean Validation** (`@Valid`, anotaciones de constraints).
- Manejo centralizado de excepciones (p. ej. `@ControllerAdvice`) con respuestas estandarizadas y `correlation_id`.

### Datos financieros y transacciones
- Usar **`BigDecimal`** para todos los importes y cálculos monetarios. **Prohibido** `float`/`double`.
- Anotar operaciones financieras con **`@Transactional`** según corresponda.
- Aplicar control de concurrencia (bloqueos de fila) cuando se modifiquen saldos/cuentas.
- Respetar idempotencia en operaciones que lo requieran.

### Multitenancy y seguridad
- Obtener `tenant_id` siempre del contexto autenticado; nunca confiar en valores enviados por el cliente.
- Filtrar datos por tenant en todas las consultas/operaciones.
- Validar permisos/roles en backend.

## Flutter y Dart (Frontend)

### Arquitectura y organización
- Organización **feature-first** (`lib/features/<feature>/...`).
- Separación de presentación, estado y acceso a datos.
- Widgets reutilizables en `shared/widgets`.

### Estado, navegación y red
- **Riverpod** como único gestor de estado.
- **GoRouter** como único sistema principal de navegación (configuración centralizada en `core/router/app_router.dart`). No usar `Navigator.push()` como mecanismo principal.
- **Dio** para comunicación HTTP, con cliente e interceptores centralizados.
- **Repositories** para acceso a API; evitar llamadas HTTP dispersas en widgets.

### Seguridad y sesión
- **Flutter Secure Storage** para datos sensibles de sesión. **Prohibido** almacenar JWT en `SharedPreferences`.
- Manejo centralizado de errores (red, autenticación, expiración de sesión).
- No implementar lógica financiera en Flutter; mostrar/validar UI, pero el backend decide.

### Operaciones y reintentos
- Generar y conservar `Idempotency-Key` (UUID) y el mismo cuerpo de solicitud en reintentos seguros de operaciones financieras.
- Incluir `X-Correlation-ID` en solicitudes según convención.

### Calidad de código Dart
- Respetar `analysis_options.yaml` y lints del proyecto.
- Preferir nombres claros, tipos explícitos cuando aporten claridad, y manejo de estados (loading/error/data).

## PostgreSQL y migraciones

- Integridad referencial mediante claves foráneas y restricciones.
- `tenant_id` en entidades correspondientes y restricciones/índices que soporten aislamiento y consultas.
- Migraciones con **Flyway**, versionadas e incrementales.
- Importes en **`NUMERIC`** (precisión/escala definida por el equipo). **Prohibido** `float`/`double`.
- No eliminar movimientos históricos; preservar trazabilidad (transacciones, asientos, auditoría).

## API y contratos

- Base path `/api/v1`.
- Respuestas estandarizadas (`success`, `code`, `message`, `data`, `correlation_id`).
- Contratos documentados y alineados entre backend y frontend antes de integrar.

## Git y revisiones

- Commits con **Conventional Commits**.
- PRs pequeños, con descripción, evidencia de pruebas y checklist completo.
- Al menos una aprobación de otro integrante antes de merge a `develop`.

## Estado actual vs. cumplimiento
- **Backend:** No aplica aún (sin código). Los estándares deberán aplicarse desde la inicialización.
- **Frontend:** Código actual es template mínimo; no cumple aún la arquitectura objetivo (Riverpod/GoRouter/Dio/estructura feature-first). La migración es pendiente. 
