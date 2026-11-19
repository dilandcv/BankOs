# AUDITORÍA TÉCNICA Y FUNCIONAL DEL FRONTEND (FLUTTER) — POST-PULL

**Fecha:** 2026-11-18  
**Componente:** `mobile/`  
**Tecnología:** Flutter 3.47.9 / Dart 3.13.7  
**Estado General:** Capa de red y repositorios implementados; `MockData.dart` eliminado; 17 pruebas unitarias pasando; **5 suites bloqueadas por errores de compilación**.  

---

## 1. Nueva Arquitectura del Frontend

Tras incorporar los commits del otro portátil (`a5b5f5b`, `d49167f`, `f19949c`), la estructura de `mobile/lib/` evolucionó de una maqueta estática a una arquitectura limpia por capas (Dominio, Datos, Presentación) y por módulos de negocio:

```text
mobile/lib/
├── app.dart                                # Configuración de MaterialApp.router con TenantTheme
├── main.dart                               # Entrypoint con ProviderScope
├── core/
│   ├── config/api_config.dart              # Base URL configurable y endpoints
│   ├── network/
│   │   ├── api_client.dart                 # Cliente Dio centralizado con interceptores
│   │   ├── api_endpoints.dart              # Mapeo de rutas REST (/api/v1)
│   │   ├── api_exception.dart              # Mapeo de errores de red y HTTP
│   │   ├── api_response.dart               # Deserialización del envelope ApiResponse
│   │   └── idempotency_key.dart            # Interceptor y generador de Idempotency-Key UUID
│   ├── providers.dart                      # Instanciación global de apiClient y storage
│   ├── router/app_router.dart              # GoRouter con guards y redirección por sesión
│   ├── security/biometric_service.dart     # Autenticación biométrica con local_auth
│   ├── session/auth_session.dart           # Modelo inmutable de sesión y token JWT
│   ├── storage/secure_session_store.dart   # Almacenamiento seguro por banco (multi-tenant)
│   ├── theme/tenant_theme.dart             # Theming dinámico según primary_color del banco
│   └── utils/input_validators.dart         # Validadores de formularios (correo, montos, etc.)
├── features/
│   ├── accounts/ (data: AccountModel, AccountsRepository, providers; presentation: screens)
│   ├── admin/ (presentation: admin_hub_screen, access_denied_screen)
│   ├── audit/ (data: AuditLogModel, AuditRepository, providers; presentation: audit_screen)
│   ├── auth/ (data: AuthRepository, auth_providers; presentation: login_screen)
│   ├── customers/ (data: CustomerModel, CustomersRepository; presentation: customers_screen)
│   ├── dashboard/ (presentation: dashboard_screen, master_dashboard_screen)
│   ├── settings/ (data: AppSettingsModel, SettingsRepository; presentation: settings_screen)
│   ├── tenants/ (data: TenantModel, TenantsRepository; presentation: screens, switcher)
│   ├── transactions/ (data: TransactionModel, TransactionsRepository; presentation: screens)
│   ├── users/ (data: UserModel, UsersRepository; presentation: users_screen)
│   └── webhooks/ (data: WebhookModel, WebhooksRepository; presentation: webhooks_screen)
└── shared/
    ├── constants/app_colors.dart           # Paleta base
    ├── utils/money_formatter.dart          # Formateador de moneda con precisión Decimal
    └── widgets/                            # Componentes reutilizables, selectores, modales
```

---

## 2. Inspección Detallada por Componentes

### 2.1 Eliminación de Mocks
- **`MockData.dart` ha sido completamente eliminado del repositorio** en el commit `a5b5f5b`.
- Ya no existen listas estáticas en memoria (`MockData.accounts`, `MockData.transactions`, `MockData.userName`).
- Todas las pantallas y repositorios leen y escriben a través de `ApiClient` e inyectan estado reactivo con Riverpod.

### 2.2 Capa de Red y Comunicación HTTP (`ApiClient`)
- Implementado sobre `Dio: ^5.11.1`.
- **`CorrelationInterceptor`:** Inyecta automáticamente `X-Correlation-ID: <UUID>` en cada petición.
- **`IdempotencyInterceptor`:** Detecta rutas financieras (`/deposits`, `/withdrawals`, `/transfers`) e inyecta la cabecera `Idempotency-Key: <UUID>` obligatoria, reutilizando la llave si el cuerpo no varía.
- **`AuthInterceptor`:** Inyecta `Authorization: Bearer <JWT>` usando el token del banco activo almacenado en `SecureSessionStore`.
- **`ErrorInterceptor`:** Si recibe un `401 UNAUTHORIZED`, limpia automáticamente el banco activo para forzar relogin.

### 2.3 Almacenamiento Seguro Multi-Banco (`SecureSessionStore`)
- Implementado con `flutter_secure_storage: ^11.2.0`.
- Almacena un token JWT independiente por cada institución (`tenant_code`), permitiendo al usuario cambiar rápidamente de banco mediante `BankSwitcherBottomSheet` sin invalidar las demás sesiones activas.

### 2.4 Gestión de Estado (Riverpod)
- Se incorporaron `StateNotifierProvider` y `FutureProvider` en cada dominio (`authSessionProvider`, `accountsProvider`, `transactionsProvider`, `tenantsProvider`, `tenantThemeProvider`).
- Las pantallas reaccionan a estados `AsyncLoading`, `AsyncData` y `AsyncError`.

### 2.5 Pruebas Automatizadas en Móvil
- Se introdujo una suite de pruebas con 9 archivos de test y fixtures JSON en `mobile/test/fixtures/`.
- **17 pruebas unitarias pasando al 100%:**
  - `auth_session_test.dart` (2 tests exitosos)
  - `api_client_test.dart` (6 tests exitosos)
  - `api_response_test.dart` (4 tests exitosos)
  - `secure_session_store_test.dart` (5 tests exitosos)

---

## 3. Problemas Críticos Encontrados (Errores de Compilación en Flutter)

A pesar del notable avance estructural, el código traído del otro portátil **no compila limpiamente**, generando fallos en 5 suites de prueba y en el análisis estático:

1. **Métodos `delete` y `patch` ausentes en `ApiClient`:**
   - En `mobile/lib/features/auth/data/auth_repository.dart`:
     - Línea 153: `await _api.delete<dynamic>(ApiEndpoints.userBankById(linkId));`
     - Línea 160: `await _api.patch<dynamic>(ApiEndpoints.userBankDefault(linkId));`
   - Sin embargo, `ApiClient` en `mobile/lib/core/network/api_client.dart` solo define `request`, `get`, `post` y `put`. Faltan los métodos envoltorios `delete` y `patch`.
2. **Propiedad `AppColors.error` inexistente:**
   - En `mobile/lib/shared/constants/app_colors.dart` se definió:
     ```dart
     static const Color danger = Color(0xFFB3261E);
     ```
   - Múltiples pantallas (`login_screen.dart`, `master_dashboard_screen.dart`, `profile_screen.dart`, `add_bank_sheet.dart`, `bank_switcher_bottom_sheet.dart`) intentan acceder a `AppColors.error`, provocando:
     `Error: Member not found: 'error'`.
3. **Falta de importación de `Color` en suite de pruebas:**
   - En `mobile/test/features/master_auth_and_switcher_test.dart:169`:
     ```dart
     expect(container.read(tenantThemeProvider).primary, const Color(0xFF6E2585));
     ```
     Arroja: `Error: Couldn't find constructor 'Color'` por omitir `import 'dart:ui';` o `import 'package:flutter/material.dart';`.

---

## 4. Estado de las Pantallas del Frontend

| Pantalla | Conectada a API | Usa Repositorio Real | Compila | Estado |
|---|:---:|:---:|:---:|---|
| Login | SÍ (`AuthRepository`) | SÍ | Error (`AppColors.error`) | **PARCIAL (Bloqueada por compilación)** |
| Master Dashboard | SÍ (`tenantsProvider`) | SÍ | Error (`AppColors.error`) | **PARCIAL (Bloqueada por compilación)** |
| Dashboard Banco | SÍ (`accountsProvider`) | SÍ | Error (`AppColors.error`) | **PARCIAL (Bloqueada por compilación)** |
| Cuentas | SÍ (`AccountsRepository`) | SÍ | SÍ | **IMPLEMENTADA (Pendiente validación E2E)** |
| Detalle de Cuenta | SÍ (`AccountsRepository`) | SÍ | SÍ | **IMPLEMENTADA (Pendiente validación E2E)** |
| Transacciones | SÍ (`TransactionsRepository`) | SÍ | SÍ | **IMPLEMENTADA (Pendiente validación E2E)** |
| Detalle Transacción | SÍ (`TransactionsRepository`) | SÍ | SÍ | **IMPLEMENTADA (Pendiente validación E2E)** |
| Transferencias / Preview | SÍ (`TransactionsRepository`) | SÍ | SÍ | **IMPLEMENTADA (Pendiente validación E2E)** |
| Depósitos y Retiros | SÍ (`TransactionsRepository`) | SÍ | SÍ | **IMPLEMENTADA (Pendiente validación E2E)** |
| Perfil | SÍ (`AuthRepository`) | SÍ | Error (`AppColors.error`) | **PARCIAL (Bloqueada por compilación)** |
| Switcher de Bancos | SÍ (`SecureSessionStore`) | SÍ | Error (`AppColors.error`) | **PARCIAL (Bloqueada por compilación)** |
| Admin Hub / Backoffice | SÍ (`Users`, `Customers`, `Audit`) | SÍ | SÍ | **IMPLEMENTADA** |
