# Modelo multi-banco (Opción A)

> **Estado:** decisión de producto adoptada el 2026-11-16. El **backend** ya implementa este modelo; `mobile/` **no** fue modificado en esta fase.

## 1. Decisión

BankOS es una sola aplicación con **múltiples instituciones (bancos)**. Cada institución es un **tenant** aislado.

Se adopta la **Opción A**:

- El usuario inicia sesión **una vez por banco** (`tenant_code + email + password`).
- Un usuario pertenece a **una sola institución**.
- La app puede guardar **varios tokens**, uno por banco, y cambiar entre ellos sin volver a escribir credenciales.
- Al cambiar de banco cambian los datos, el branding y el tema visual.
- El backend no mantiene una “sesión global”: cada JWT está atado a un `tenant_id`.

## 2. Qué significa en el backend

| Aspecto | Implementación |
|---|---|
| Tenant | `tenants.id`, `tenants.code`, `tenants.name`, `status` y branding (`primary_color`, `secondary_color`, `logo_url`). |
| Usuario | `users.tenant_id` obligatorio. Email único por tenant, no global. |
| Login | `POST /api/v1/auth/login` con `tenant_code`, `email`, `password`. |
| JWT | Claims `sub`, `tenant_id`, `email`, `roles`, `iss`, `jti`, `iat`, `exp`. |
| Aislamiento | Todo repositorio/servicio filtra por el `tenant_id` del JWT mediante `TenantContext`. |
| Roles | `PLATFORM_ADMIN`, `TENANT_ADMIN`, `OPERATOR`, `AUDITOR`. |
| Platform | `PLATFORM_ADMIN` vive en el tenant reservado `PLATFORM`. |
| Branding | El login y `/auth/me` devuelven los colores/logo del tenant para que el cliente aplique el tema. |
| Sesiones | Sin refresh token ni tabla de sesiones en el MVP. El cliente guarda un token por banco. |

### Ejemplo de login

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "tenant_code": "NEQUI",
  "email": "admin@nequi.com",
  "password": "Admin123!"
}
```

```json
{
  "success": true,
  "code": "LOGIN_SUCCESS",
  "message": "Sesión iniciada correctamente",
  "data": {
    "access_token": "eyJ...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "user": {
      "id": "...",
      "email": "admin@nequi.com",
      "full_name": "Admin Nequi",
      "role": "TENANT_ADMIN"
    },
    "tenant": {
      "id": "...",
      "code": "NEQUI",
      "name": "Nequi",
      "primary_color": "#6E2585",
      "secondary_color": "#A64AC9",
      "logo_url": null
    }
  },
  "correlation_id": "..."
}
```

## 3. Bancos demo

| Tenant | Código | Color primario | Color secundario |
|---|---|---|---|
| BankOS Platform | `PLATFORM` | `#0B1F3A` | `#0070BA` |
| Nequi | `NEQUI` | `#6E2585` | `#A64AC9` |
| Daviplata | `DAVIPLATA` | `#E30613` | `#FF5A5F` |
| PayPal | `PAYPAL` | `#003087` | `#0070BA` |
| Bancolombia | `BANCOLOMBIA` | `#FFD100` | `#1B1B1B` |
| NU | `NU` | `#820AD1` | `#B15CFF` |
| Banco Horizonte | `BANCO_HORIZONTE` | `#0070BA` | `#003087` |

Los colores son valores de demostración; el branding definitivo debe validarse con cada marca.

## 4. Modelo de sesiones en la app (futuro frontend)

La app debe evolucionar de “un solo banco mock” a:

1. Una pantalla de selección de banco/institución.
2. Un login por banco que envíe `tenant_code`.
3. Almacenamiento seguro de un token por `tenant_code`.
4. Un `activeTenantProvider` que determine el banco actual.
5. Un tema dinámico construido desde `primary_color`/`secondary_color` del tenant activo.
6. Repositorios/providers con `tenantId` en sus claves de cache.
7. Un selector de banco que cambie la sesión activa sin mezclar datos.
8. Manejo de expiración: si el token del banco activo expiró, pedir login solo para ese banco.

Estructura conceptual del almacenamiento local:

```text
sessions/
  NEQUI          -> token + tenant metadata
  DAVIPLATA      -> token + tenant metadata
  PAYPAL         -> token + tenant metadata
active_tenant -> NEQUI
```

## 5. Pendientes explícitos del frontend

Estos puntos **no** se implementaron en esta fase porque el alcance fue solo backend:

- Eliminar el nombre fijo `Banco Horizonte` de `mobile/lib/shared/constants/mock_data.dart` como fuente de verdad.
- Reemplazar el tema estático de `mobile/lib/shared/constants/app_colors.dart` y `mobile/lib/app.dart` por un tema por tenant.
- Agregar selector de banco y pantalla de login por institución.
- Agregar almacenamiento seguro multi-token (Flutter Secure Storage).
- Agregar cliente HTTP (Dio) y contratos API.
- Migrar los datos mock a repositorios reales o mocks por tenant.
- Manejar cambio de banco, cierre de sesión por banco y expiración de token.
- Agregar pruebas de aislamiento de datos en el cliente.

## 6. Límites conocidos del MVP backend

- No hay refresh tokens; el cliente debe volver a autenticarse cuando expire el access token.
- No hay tabla de sesiones ni revocación centralizada de tokens.
- No hay RLS de PostgreSQL; el aislamiento se hace con filtros explícitos y pruebas.
- El registro/onboarding público de instituciones no está implementado; `POST /api/v1/tenants` requiere `PLATFORM_ADMIN`.
- La comisión de transferencia no se contabiliza en una cuenta de ingresos; se descuenta del origen. La doble partida estricta queda como evolución.
- El dispatcher de webhooks corre dentro de la misma aplicación; un worker separado queda para producción.
