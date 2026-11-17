# Arquitectura del frontend — BankOS

> **Estado (2026-11-17):** `mobile/` existe y funciona como prototipo con datos mock. **No fue modificado ni conectado al backend** en esta fase. La integración multi-banco es trabajo futuro.

## Estado actual auditado

- Proyecto Flutter en `mobile/` con estructura feature-first.
- Dependencias actuales: `flutter_riverpod` y `go_router`.
- `main.dart` usa `ProviderScope`; `app.dart` usa `ConsumerWidget` y `MaterialApp.router`.
- Navegación centralizada en `core/router/app_router.dart`.
- Pantallas: login, dashboard, cuentas, detalle de cuenta, transacciones, depósito, retiro, transferencia, preview y perfil.
- Datos mock en `shared/constants/mock_data.dart`.
- No hay cliente HTTP, almacenamiento seguro de tokens ni integración con el backend.
- La app representa un solo banco; no existe selector de institución ni manejo de múltiples sesiones.

## Estructura actual

```text
mobile/lib/
├── main.dart
├── app.dart
├── core/
│   └── router/app_router.dart
├── features/
│   ├── authentication/presentation/login_screen.dart
│   ├── dashboard/presentation/dashboard_screen.dart
│   ├── accounts/presentation/{accounts_screen,account_detail_screen}.dart
│   ├── transactions/presentation/{transactions_screen,deposit_screen,withdrawal_screen,transfer_screen,transfer_preview_screen}.dart
│   └── profile/presentation/profile_screen.dart
└── shared/
    ├── constants/{app_colors,mock_data}.dart
    └── widgets/{app_scaffold,account_card,balance_card,primary_button,transaction_tile}.dart
```

## Navegación

- GoRouter es el sistema de navegación.
- Rutas actuales: login, dashboard, cuentas, detalle, transacciones, depósito, retiro, transferencia, preview y perfil.
- No hay guardas de autenticación reales ni selección de banco.

## Estado

- Riverpod está configurado a nivel de app (`ProviderScope`).
- No existen providers de sesión, cuentas o transacciones conectados a backend.
- Las pantallas consumen datos mock.

## Datos y red

- No hay Dio ni otro cliente HTTP.
- No hay DTOs ni repositorios de API.
- No hay `flutter_secure_storage`, `local_auth` ni `uuid`.
- No se genera `Idempotency-Key` ni `X-Correlation-ID`.

## Modelo multi-banco pendiente

La app debe evolucionar a la **Opción A**:

1. Selector de institución.
2. Login por institución (`tenant_code + email + password`).
3. Guardar un token por banco de forma segura.
4. Cambiar de sesión sin volver a autenticarse.
5. Aplicar branding del tenant (`primary_color`, `secondary_color`, `logo_url`).
6. Enviar el token de la institución activa en cada llamada.
7. Conservar `Idempotency-Key` y el mismo cuerpo en reintentos financieros.

Ver [modelo multi-banco](multi-bank-model.md).

## Integración futura con el backend

- Base URL: `http://localhost:8080` en desarrollo.
- Base path: `/api/v1`.
- Login: `POST /api/v1/auth/login`.
- Header: `Authorization: Bearer <token>`.
- Operaciones financieras: `Idempotency-Key`.
- Errores: mapear `code` y conservar `correlation_id`.
- No enviar `tenant_id` desde la app.

## Pendiente

- Agregar `dio`, `flutter_secure_storage`, `local_auth` y `uuid`.
- Implementar sesión multi-token y selector de banco.
- Crear cliente HTTP con interceptores.
- Reemplazar mocks por repositorios reales.
- Guardas de navegación y manejo de sesión expirada.
- Pruebas de integración y E2E.
- Branding dinámico por institución.

## Reglas

- No implementar lógica financiera en Flutter.
- No almacenar JWT en `SharedPreferences`.
- No usar `Navigator.push()` como mecanismo principal.
- No modificar el backend desde el frontend ni asumir contratos no documentados.
