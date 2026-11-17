# Autenticación — BankOS

> **Estado (2026-11-17):** implementada en el backend. La fuente canónica está en [`backend/docs/security/authentication.md`](../../backend/docs/security/authentication.md).

## Modelo multi-banco

- Cada institución es un tenant.
- El login requiere `tenant_code + email + password`.
- El usuario pertenece a un solo tenant.
- El cliente puede guardar un token por institución y cambiar de sesión.

## Login

```http
POST /api/v1/auth/login
Content-Type: application/json
```

```json
{
  "tenant_code": "BANCO_HORIZONTE",
  "email": "admin@horizonte.com",
  "password": "Admin123!"
}
```

La respuesta incluye:

- `access_token`
- `token_type` (`Bearer`)
- `expires_in`
- `user` (`id`, `email`, `full_name`, `role`)
- `tenant` (`id`, `code`, `name`, branding)

## JWT

- Algoritmo HS256.
- Claims: `sub`, `tenant_id`, `email`, `roles`, `iss`, `iat`, `exp`.
- Expiración configurable con `JWT_EXPIRATION_MS` (default 1 hora).
- Secreto configurable con `JWT_SECRET`; en producción debe ser aleatorio y de al menos 32 bytes.

## Contraseñas

- BCrypt con strength 12.
- No se registran contraseñas ni tokens en logs.

## Roles

| Rol | Alcance |
|---|---|
| `PLATFORM_ADMIN` | Administración de la plataforma; tenant `PLATFORM`. |
| `TENANT_ADMIN` | Administración de su institución. |
| `OPERATOR` | Operaciones financieras y clientes. |
| `AUDITOR` | Consulta de historial y auditoría. |

Los permisos se validan en backend con `@PreAuthorize`.

## Sesiones

- JWT stateless; no hay sesión de servidor.
- El cliente almacena tokens de forma segura.
- Logout local = eliminar el token de esa institución.

## Pendiente

- Refresh tokens y rotación.
- Revocación centralizada de sesiones.
- Rate limiting y bloqueo por intentos fallidos.
- MFA.

## Documentación relacionada

- [Autenticación del backend](../../backend/docs/security/authentication.md)
- [Multitenancy](multitenancy.md)
- [Modelo multi-banco](../architecture/multi-bank-model.md)
