# Cliente Flutter — BankOS

App móvil/web de BankOS conectada al backend Spring Boot real (`/api/v1`). Sin mocks: todas las pantallas consumen la API.

> Plan y decisiones: [`docs/mobile-integration-plan.md`](../docs/mobile-integration-plan.md) y [`docs/mobile-integration-decisions.md`](../docs/mobile-integration-decisions.md). Contrato de la API: [`backend/docs/api/api-contracts.md`](../backend/docs/api/api-contracts.md).

## Requisitos

- Flutter (Dart SDK `^3.13.7`).
- Backend `dev` arriba en `http://localhost:8080` (`docker compose up -d` en la raíz).
- Web: navegador con CORS permitido (el backend ya habilita `http://localhost:*` y `http://127.0.0.1:*`).
- Android emulator / iOS simulator: ver base URL abajo.

## Base URL

`lib/core/config/api_config.dart` resuelve el host automáticamente y añade el base path `/api/v1`:

| Plataforma | Host por defecto |
|---|---|
| Flutter web | `http://localhost:8080` |
| iOS simulator | `http://localhost:8080` |
| Android emulator | `http://10.0.2.2:8080` |

Override en tiempo de compilación:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

Permisos nativos ya configurados: INTERNET y cleartext en Android debug, ATS para localhost y Face ID en iOS.

## Ejecutar

```bash
flutter pub get
flutter run -d chrome                      # web
flutter run -d emulator-5554               # Android emulator
flutter run -d "iPhone 15 Simulator"       # iOS simulator
```

Login demo del seed:

- Institución: `BANCO_HORIZONTE`
- Correo: `admin@horizonte.com`
- Contraseña: `Admin123!`

## Arquitectura

Feature-first + Riverpod + GoRouter + Dio + repositorios. Ningún widget llama a Dio directamente.

```
lib/
├── core/
│   ├── config/api_config.dart       # base URL + /api/v1
│   ├── network/                     # ApiClient, endpoints, envelope, paginación, excepciones
│   │   └── api_client.dart          # interceptores: Bearer, correlación, idempotencia, errores, 401
│   ├── session/auth_session.dart    # usuario, tenant y permisos por rol
│   ├── storage/secure_session_store.dart  # JWT por tenant_code + flag biométrico
│   ├── security/biometric_service.dart
│   ├── router/app_router.dart       # guards de sesión y de rol, rutas /admin/*
│   └── providers.dart
├── features/
│   ├── authentication/  dashboard/  accounts/  transactions/  profile/
│   ├── tenants/                      # selector multi-banco + alta admin
│   ├── users/  customers/  settings/  audit/  webhooks/        # F4
│   └── admin/presentation/           # hub por rol y /forbidden
└── shared/                           # tema, widgets y utilidades
```

## Funcionalidad conectada

- **Autenticación:** login real por banco, `/auth/me`, guardas de router, logout local por tenant y 401 que obliga a relogin de ese banco.
- **Operaciones:** cuentas, detalle de cuenta, historial paginado/filtrable, depósito, retiro, transferencia con preview y detalle de movimiento con asientos contables.
- **Multi-banco:** varios tokens simultáneos por `tenant_code`, cambio sin re-login, expiración por banco y tema dinámico desde `primary_color`/`secondary_color`/`logo_url`.
- **Administración según rol:** usuarios, clientes, configuración/tasas, auditoría, webhooks/outbox e instituciones. Las pantallas espejean los `@PreAuthorize` del backend; una ruta sin permiso redirige a `/forbidden`.

Roles y permisos (espejo del backend):

| Módulo | Roles con acceso |
|---|---|
| Usuarios | `PLATFORM_ADMIN`, `TENANT_ADMIN` |
| Clientes (listar / crear) | todos / `TENANT_ADMIN`, `OPERATOR` |
| Configuración y tasas (leer / escribir) | todos / `PLATFORM_ADMIN`, `TENANT_ADMIN` |
| Auditoría y webhooks (leer) | `PLATFORM_ADMIN`, `TENANT_ADMIN`, `AUDITOR` |
| Webhooks (crear) | `PLATFORM_ADMIN`, `TENANT_ADMIN` |
| Crear institución | `PLATFORM_ADMIN` |

## Seguridad y dinero

- El JWT vive solo en `flutter_secure_storage`, nunca en SharedPreferences ni en logs.
- Biometría = **desbloqueo local del token ya guardado** (“Desbloquear con biometría”). No es MFA, no autentica ante el backend y no renueva tokens vencidos.
- Importes como `String` + `decimal`; está prohibido usar `double` para dinero.
- `Idempotency-Key` UUID estable por operación financiera: el mismo key y el mismo body en reintentos; nunca se genera una llave nueva para reintentar. `POST /transfers/preview` no es financiero.

## Calidad

```bash
flutter analyze
flutter test
flutter build web --release --no-wasm-dry-run
flutter build apk --release
```

Estado: `analyze` sin issues, **46 tests en verde**, build web y APK OK.

Los tests usan `test/helpers/fake_adapter.dart` y las respuestas congeladas de `test/fixtures/` (token `<REDACTED>`, sin secretos). Tras guardar sesión en tests Riverpod, llamar a `sessionControllerProvider.notifier.setSession(session)` para evitar la carrera del `FutureProvider`.

### Advertencias de build conocidas

- El template advierte que Gradle `9.3.1`, AGP `9.1.1` y Kotlin `2.4.10` dejarán de tener soporte pronto; el build actual funciona. No se actualizaron en este plan para no introducir riesgo.
- Aviso de fuentes `CupertinoIcons` durante el build Android: `cupertino_icons` está en el grafo pero no se usa; no afecta al resultado.

## Alcance

`mobile/` **no está en Docker** en este plan. Tampoco se modificó el comportamiento del backend: los únicos cambios fuera de `mobile/` son correcciones documentales del contrato en F5.
