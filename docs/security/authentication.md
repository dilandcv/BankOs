# Autenticación — BankOS

## Estado
- **Implementado (auditado):** No existe autenticación. No hay Spring Security, JWT, endpoints de login, ni manejo de sesión en Flutter.
- **Objetivo:** Autenticación basada en **JWT**, roles/permisos validados en backend, sesión segura en móvil.

## Mecanismo objetivo (JWT)

1. El usuario envía credenciales a `POST /api/v1/auth/login` (propuesto).
2. Backend valida credenciales y pertenencia/estado de tenant y usuario.
3. Backend emite JWT con claims necesarios (propuesto: identidad, `tenant_id`, roles, expiración).
4. Frontend almacena el token en **Flutter Secure Storage**.
5. Dio adjunta `Authorization: Bearer <JWT>` en solicitudes protegidas.
6. Spring Security valida firma/expiración y construye el contexto de seguridad por solicitud.

> **Pendientes:** Algoritmo de firma, rotación de claves, expiración, refresh tokens, revocación/logout server-side y claims definitivos.

## Roles y permisos (objetivo)
- Definir roles por tenant (ej. administrador, operador, auditor) — **pendiente de catálogo definitivo**.
- Autorización en backend por endpoint/acción (Spring Security / anotaciones / políticas).
- Control de acceso en frontend (GoRouter guards) como mejora de UX, **nunca** como única barrera.

## Gestión de sesiones (objetivo)
- Sesión representada por token seguro en almacenamiento del dispositivo.
- Manejo de expiración: detectar 401/token expirado, limpiar sesión y redirigir a `/login`.
- Cierre de sesión: limpiar tokens/estado local y navegar a `/login` vía GoRouter.
- **Local Auth** (biometría) puede facilitar reingreso, pero no reemplaza la validez del token backend (pendiente de diseño).

## Almacenamiento seguro
- **Obligatorio:** Flutter Secure Storage para JWT/datos sensibles.
- **Prohibido:** `SharedPreferences` para JWT.
- No registrar tokens en logs.

## Protección de endpoints
- Endpoints protegidos requieren JWT válido.
- Validación de roles/permisos por operación.
- Rate limiting para autenticación y endpoints sensibles (propuesto, no implementado).

## Estado actual de cumplimiento
- Backend: sin dependencias/configuración de seguridad.
- Frontend: sin interceptor de auth, sin storage seguro, sin guards de ruta. 
