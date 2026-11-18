# Plan de integración y cierre de Flutter — BankOS

> Aprobado el 2026-11-17. Ejecución por fases. Decisiones en [`mobile-integration-decisions.md`](mobile-integration-decisions.md).

## Principios

1. Conectar primero lo que ya existe en `mobile/`; después agregar lo que falta.
2. Backend como fuente de verdad: sin lógica financiera en Flutter.
3. feature-first + Riverpod + GoRouter + Dio + repositories.
4. Dinero como `String`/`Decimal`; nunca `double`.
5. JWT solo en `flutter_secure_storage`.
6. `Idempotency-Key` estable por operación; sin reintentos financieros con llave nueva.
7. **No agregar `mobile/` a Docker** en este plan.
8. No cambiar comportamiento del backend sin autorización.

## Fase 0 — Arranque y contrato validado ✅

- [x] Rama `feature/mobile-backend-integration` desde `develop`.
- [x] Backend `UP` con PostgreSQL y Redis.
- [x] Login, `/auth/me`, `/accounts/all`, `/transactions` y preview verificados.
- [x] Fixtures sanitizados en `mobile/test/fixtures/`.
- [x] Base URL y decisiones documentadas.
- [x] Decisión de biometría (M0-11): opción A aplicada en F3.

## Fase 1 — Núcleo de integración ✅

- [x] Dependencias: `dio`, `flutter_secure_storage`, `uuid`, `decimal`, `local_auth` (biometría A).
- [x] `ApiEndpoints`, `ApiClient` (Dio) e interceptores: Bearer, `X-Correlation-ID`, `Idempotency-Key`, errores, 401.
- [x] `SecureSessionStore` por `tenant_code` + bandera de biometría por banco.
- [x] DTOs y `AuthRepository` (`login`, `me`, `switchTenant`, `logoutTenant`, `getSessions`).
- [x] Providers Riverpod de API, sesión, tenant activo, tema, biometría y errores.
- [x] Permisos nativos: Android INTERNET/cleartext dev, iOS ATS local + Face ID; CORS web documentado en el backend.
- [x] Tests unitarios de envelope, errores, headers e idempotencia: **17 en verde**, `flutter analyze` limpio.

## Fase 2 — Conectar lo que ya existe ✅

- [x] Guardas de router y login real (`tenant_code` + email + password).
- [x] Dashboard con usuario/tenant/cuentas/movimientos y saldo agregado por moneda (`Decimal`).
- [x] Cuentas y detalle con cuentas reales y filtro `accountId` en el historial.
- [x] Transacciones con historial paginado y filtros funcionales por tipo y cuenta.
- [x] Depósito/retiro con `Idempotency-Key` estable y errores normalizados.
- [x] Transferencia + preview reales con comprobante.
- [x] Perfil real, toggle de desbloqueo biométrico y logout local.
- [x] Widgets tipados y eliminación de `MockData`. El tema del tenant se aplica en F3.
- [x] Tests de providers del flujo principal: **23 en verde**, `flutter analyze` limpio y `flutter build web` OK.

## Fase 3 — Multi-banco y tema dinámico ✅

- [x] Catálogo/selector de instituciones (`BanksScreen`, ruta `/banks`, tile en perfil).
- [x] Múltiples tokens por banco y cambio sin re-login (`switchTenant`).
- [x] Providers por tenant y tema desde `primary_color`/`secondary_color`/`logo_url`.
- [x] Expiración por banco y relogin parcial (`initialTenantCode` en login).
- [x] Biometría opción A: desbloqueo local del token guardado, rotulado “Desbloquear con biometría”.
- [x] Tests de aislamiento entre tenants: **28 en verde**, `flutter analyze` limpio.

## Fase 4 — Funciones pendientes ✅

- [x] Navegación y 403 por rol: `canAccessAdminPath`, `/forbidden`, hub por rol y tile “Administración” en perfil.
- [x] Detalle de transacción: `transactionByIdProvider`, `TransactionDetailScreen` con asientos y `onTap` en `TransactionTile`.
- [x] Clientes, usuarios, settings/tasas, auditoría, webhooks/outbox y tenants admin (repositorios + providers + pantallas espejo de los `@PreAuthorize`).
- [x] Tests por feature: permisos por rol, `GET /transactions/{id}`, altas admin y 403: **46 en verde**, `flutter analyze` limpio y build web OK.

## Fase 5 — Calidad y cierre ✅

- [x] `flutter analyze` limpio, `flutter test` **46 en verde**, `flutter build web --no-wasm-dry-run` y `flutter build apk` OK.
- [x] `mobile/README.md` reescrito y documentación global actualizada (plan + decisiones).
- [x] Corrección documental de discrepancias del contrato (solo docs): claves camelCase en validación, 409 en `GET /exchange-rates/{id}`, outbox paginado y 500 por `@PreAuthorize` denegado.
- [x] Smoke/E2E real contra el backend con token redactado; evidencia en `mobile-integration-decisions.md`.
- [x] Checklist final: sin secretos en fixtures, sin mocks en runtime, `mobile/` fuera de Docker, backend sin cambios de comportamiento.

## Criterio de salida global

Flujo demo real: login multi-banco → dashboard → depósito/retiro/transferencia → historial → administración según rol, con tests en verde y documentación alineada.
