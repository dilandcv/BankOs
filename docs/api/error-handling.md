# Manejo de errores — BankOS

## Estado
- **Implementado (auditado):** No hay manejo de errores de API implementado (sin backend ni cliente HTTP configurado).
- **Objetivo:** Errores consistentes, trazables y seguros en backend y frontend.

## Formato de error estándar (objetivo)

```json
{
  "success": false,
  "code": "INSUFFICIENT_FUNDS",
  "message": "Saldo insuficiente",
  "data": null,
  "correlation_id": "uuid"
}
```

- `code`: identificador estable para manejo programático (frontend/tests).
- `message`: mensaje claro para usuario/desarrollador, sin exponer detalles sensibles.
- `correlation_id`: permite rastrear la solicitud en logs.

## Backend (propuesto)

### Principios
- Manejo centralizado de excepciones (p. ej. `@RestControllerAdvice`).
- Mapear excepciones de dominio/validación/seguridad a códigos HTTP y `code` de negocio coherentes.
- Incluir/propagar `X-Correlation-ID` (generar si no llega, según política) y devolverlo en `correlation_id`.
- No exponer stack traces, SQL, ni detalles internos en respuestas.

### Categorías y mapeo orientativo

| Situación | HTTP (sugerido) | `code` ejemplo |
|---|---:|---|
| Error de validación de entrada | 400 | `VALIDATION_ERROR` |
| Credenciales inválidas | 401 | `INVALID_CREDENTIALS` |
| Token ausente/inválido/expirado | 401 | `UNAUTHORIZED` / `TOKEN_EXPIRED` |
| Sin permisos o acceso a otro tenant | 403 | `FORBIDDEN` / `TENANT_ACCESS_DENIED` |
| Recurso no encontrado | 404 | `*_NOT_FOUND` |
| Conflicto de estado/negocio | 409 | `IDEMPOTENCY_CONFLICT`, `CONFLICT` |
| Regla financiera (saldo insuficiente) | 422 o 409 (definir) | `INSUFFICIENT_FUNDS` |
| Cuenta inactiva/bloqueada | 422 o 403 (definir) | `ACCOUNT_INACTIVE`, `ACCOUNT_BLOCKED` |
| Límite de tasa excedido | 429 | `RATE_LIMITED` |
| Error interno | 500 | `INTERNAL_ERROR` |

> Los códigos HTTP y de negocio exactos son **pendientes de estandarización**; deben ser consistentes en toda la API.

### Errores financieros y de concurrencia
- Rechazar operaciones inválidas sin modificar saldos (atomicidad).
- En conflictos de idempotencia, responder de forma determinista (misma respuesta previa o error controlado, según diseño).
- Proteger contra condiciones de carrera con transacciones y bloqueos adecuados.

## Frontend (propuesto)

### Principios (Dio + Riverpod)
- Interceptores Dio para:
  - Inyectar headers (`Authorization`, `X-Correlation-ID`, `Idempotency-Key` cuando aplique).
  - Normalizar errores de red/timeout/HTTP a un modelo de error común.
- Reintentos **solo cuando sean seguros**; operaciones financieras deben reutilizar `Idempotency-Key` y mismo body.
- Manejo de sesión expirada: limpiar estado seguro y redirigir a `/login` vía GoRouter.
- Presentar mensajes claros al usuario sin exponer información sensible.

### Tipos de error sugeridos (pendiente de implementación)
- `NetworkFailure` (sin conexión, timeout)
- `UnauthorizedFailure` (401, sesión expirada)
- `ForbiddenFailure` (403)
- `ValidationFailure` (400, detalles por campo si `data` lo incluye)
- `BusinessFailure` (códigos de dominio como `INSUFFICIENT_FUNDS`)
- `ServerFailure` (5xx)

## Trazabilidad
- Registrar `correlation_id`, tenant (sin datos sensibles), endpoint y resultado en logs de backend.
- Propagar `X-Correlation-ID` extremo a extremo para diagnóstico.

## Pendientes
- Catálogo definitivo de códigos de error.
- Estructura de `data` para errores de validación (campos/errores).
- Política de reintentos, backoff y timeouts en cliente.
- Integración con observabilidad (cuando exista). 
