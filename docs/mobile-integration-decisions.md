# Decisiones de integración móvil — BankOS

> Estado: Fase 0 aprobada el 2026-11-17. Plan completo en `docs/mobile-integration-plan.md` (mensaje de aprobación) y ejecución por fases F0–F5.

## Aprobadas

| ID | Decisión | Detalle |
|---|---|---|
| M0-1 | Plan por fases | F0 preparación, F1 núcleo HTTP/sesión, F2 pantallas existentes, F3 multi-banco/tema, F4 funciones pendientes, F5 calidad y cierre. |
| M0-2 | Flujo de trabajo | Rama `feature/mobile-backend-integration` desde `develop`. Sin push/PR sin autorización. Commits Conventional. |
| M0-3 | Cambios previos en Flutter | Se conservan los imports de `material_ui` ya preparados en el working tree. No se revierten. |
| M0-4 | Backend | No se modifica su comportamiento. Solo se corregirá documentación de contratos en F5 si se aprueba. |
| M0-5 | Docker | **No se agrega `mobile/` a Docker** en este plan. |
| M0-6 | Módulos admin | Se incluyen en F4: users, customers, settings/rates, audit, webhooks y tenants según rol. |
| M0-7 | Plataformas | Web + Android emulator como prioritarias; iOS simulator también configurado. Base URL por `--dart-define`. |
| M0-8 | Dinero | `String` + paquete `decimal` en Flutter. Prohibido `double` para importes. |
| M0-9 | Sesión | JWT solo en `flutter_secure_storage`. Logout local por tenant; 401 obliga a relogin de ese banco. |
| M0-10 | Operaciones financieras | `Idempotency-Key` UUID generado una vez por intento; mismo key + mismo body en reintentos. |

## Base URL de desarrollo

| Plataforma | Valor |
|---|---|
| Android emulator | `http://10.0.2.2:8080` |
| iOS simulator | `http://localhost:8080` |
| Flutter web | `http://localhost:8080` |
| Override | `--dart-define=API_BASE_URL=http://...` |

Base path: `/api/v1`. CORS del backend ya permite `http://localhost:*` y `http://127.0.0.1:*`.

## Decisión de biometría (aplicada en F3)

| ID | Decisión | Detalle |
|---|---|---|
| M0-11 | Biometría = **A: desbloqueo local** | Tras un login normal con contraseña, huella/Face ID abre el token ya guardado en almacenamiento seguro. Rotulo en UI: **“Desbloquear con biometría”**. No es MFA, no autentica ante el backend y no renueva tokens vencidos. `local_auth` se agregará en F1 y se conectará en F3. Quedan fuera de alcance B (quitar botón) y C (passkeys/WebAuthn). |

## Evidencia de Fase 0

- `docker compose ps`: backend, PostgreSQL y Redis `healthy`.
- `GET /actuator/health`: `UP` con `db` y `redis` arriba.
- Login demo `BANCO_HORIZONTE / admin@horizonte.com` → `LOGIN_SUCCESS`, rol `TENANT_ADMIN`.
- `/auth/me`, `/accounts/all`, `/transactions` y `/transfers/preview` verificados.
- Fixtures sanitizados en `mobile/test/fixtures/`.

## Evidencia de Fase 5

- `flutter analyze`: sin issues. `flutter test`: **46 en verde**.
- `flutter build web --release --no-wasm-dry-run`: OK. `flutter build apk --release`: OK (`app-release.apk`, 53.7 MB).
- Smoke E2E real contra `http://localhost:8080/api/v1` (token redactado), con `TENANT_ADMIN / BANCO_HORIZONTE`:
  - `POST /auth/login` → `LOGIN_SUCCESS`; `GET /auth/me` → `AUTH_ME`.
  - `GET /accounts/all` → 3 cuentas; `GET /transactions` → 0 movimientos (seed).
  - `POST /transfers/preview` → `TRANSFER_PREVIEW` con comisión/conversión.
  - `GET /users` (3), `/customers` (1), `/settings`, `/exchange-rates` (2), `/audit-logs` (3), `/webhooks` (0), `/webhooks/events` (0), `/tenants` (1): todos HTTP 200 con su `code`.
  - Validación `POST /deposits` sin `account_id` → `400 VALIDATION_ERROR` con `data = {"accountId": "must not be null"}` (clave camelCase, documentada).
  - `POST /tenants` con rol insuficiente → `500 INTERNAL_ERROR` por `AuthorizationDeniedException`; discrepancia documentada en `backend/docs/api/api-contracts.md`. El guard de rol del cliente impide llegar a ese endpoint.
- Checklist: sin secretos en fixtures (token `<REDACTED>`), sin mocks en runtime, `mobile/` fuera de Docker, backend sin cambios de comportamiento (solo docs).
