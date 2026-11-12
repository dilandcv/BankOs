# Arquitectura del frontend — BankOS

## Estado
- **Implementado (auditado):**
  - Proyecto Flutter en `mobile/` con estructura de plataforma estándar.
  - `mobile/lib/main.dart` contiene una app mínima (`MaterialApp` + "Hello World").
  - `pubspec.yaml` solo incluye `flutter` y dev deps (`flutter_test`, `flutter_lints`). **No** incluye Riverpod, GoRouter, Dio, `flutter_secure_storage`, `local_auth`, ni `uuid`.
- **Decisión objetivo:** Flutter con arquitectura **feature-first**, **Riverpod** para estado, **GoRouter** como única navegación, **Dio** para HTTP.

## Decisiones obligatorias

### Riverpod (gestión de estado)
Debe utilizarse para:
- Sesión del usuario y estado de autenticación.
- Estados de carga y error.
- Información de cuentas y saldos (vista).
- Operaciones financieras (orquestación de UI/llamadas, sin lógica financiera de negocio).
- Historiales y configuraciones.

**Estado actual:** No configurado.

### GoRouter (navegación obligatoria)
- **GoRouter será el único sistema principal de navegación.** No debe sustituirse por `Navigator` como mecanismo principal.
- Configuración centralizada en `core/router/app_router.dart`.
- Navegación declarativa, rutas con nombre cuando corresponda, rutas protegidas y redirecciones según autenticación.
- Control de acceso según roles, gestión de sesión expirada, cierre de sesión con redirección a login.
- Integración con Riverpod para reaccionar a cambios de sesión/rol.
- Manejo de parámetros de ruta.
- **Estado actual:** No implementado; la app usa `MaterialApp` directo.

**Rutas iniciales propuestas:**
```text
/login
/dashboard
/accounts
/accounts/:id
/transactions
/transactions/deposit
/transactions/withdrawal
/transactions/transfer
/transactions/transfer/preview
/profile
```
> La lista es inicial y puede ajustarse según el alcance; cualquier cambio debe reflejarse en esta documentación.

### Dio (cliente HTTP)
Responsabilidades objetivo:
- Cliente HTTP centralizado, configuración de base URL y timeouts.
- Interceptores para: `Authorization: Bearer <JWT>`, `X-Correlation-ID`, `Idempotency-Key` (operaciones financieras).
- Manejo centralizado de errores y mapeo a estados de UI.
- Reintentos **seguros**: una operación financiera reintentada debe conservar la **misma `Idempotency-Key` y el mismo cuerpo** de solicitud.

**Estado actual:** No configurado.

### Almacenamiento seguro
- **Flutter Secure Storage** para datos sensibles de sesión (tokens).
- **Prohibido** almacenar JWT en `SharedPreferences`.
- **Local Auth** para autenticación biométrica (objetivo, pendiente de integración).

**Estado actual:** No configurado.

## Estructura propuesta (feature-first)

```text
mobile/
└── lib/
    ├── main.dart
    ├── app.dart                      (propuesto: bootstrap de la app)
    │
    ├── core/
    │   ├── config/                   (entornos, constantes de app)
    │   ├── network/                  (cliente Dio, interceptores)
    │   ├── storage/                  (secure storage, wrappers)
    │   ├── router/
    │   │   └── app_router.dart      (GoRouter centralizado)
    │   ├── security/                 (helpers de sesión/claims si aplica)
    │   └── errors/                   (tipos y mapeo de errores)
    │
    ├── features/
    │   ├── authentication/
    │   ├── dashboard/
    │   ├── accounts/
    │   ├── transactions/
    │   ├── history/
    │   └── profile/
    │
    └── shared/
        ├── widgets/
        ├── models/
        └── constants/
```

> **Nota:** La estructura actual solo contiene `lib/main.dart`. La migración a esta estructura es **pendiente**.

## Organización por feature (patrón propuesto)

Cada feature puede incluir, según necesidad:
- `presentation/` (screens/widgets)
- `providers/` o `state/` (Riverpod providers/notifiers)
- `data/` (repositories, data sources, DTOs/modelos de API)
- `domain/` (modelos de UI/dominio ligero, si aplica)

**Reglas:**
- Separar presentación y acceso a datos (repositories para API).
- No implementar lógica financiera en Flutter; el backend es la autoridad.
- Reutilizar widgets compartidos en `shared/widgets`.

## Integración GoRouter + Riverpod + sesión (objetivo)

- Un provider de autenticación/sesión expondrá estado (anónimo, autenticado, expirado, cargando).
- `app_router.dart` consumirá ese estado (vía `refreshListenable`/`redirect` o patrón equivalente soportado por la versión de GoRouter usada) para:
  - Redirigir usuarios no autenticados a `/login`.
  - Restringir rutas por rol cuando aplique.
  - Manejar expiración de sesión y forzar redirección a login.
  - Limpiar estado y navegar a `/login` en cierre de sesión.

**Pendiente:** Selección de versiones compatibles de paquetes y patrón exacto de integración (GoRouter cambia APIs entre versiones).

## Reglas de implementación

- No usar `Navigator.push()` como mecanismo principal de navegación.
- No almacenar JWT en `SharedPreferences`.
- Conservar `Idempotency-Key` y cuerpo durante reintentos de operaciones financieras.
- Manejo centralizado de errores de red y sesión.

## Dependencias a agregar (pendiente)

En `pubspec.yaml` deberán incluirse, entre otras: `flutter_riverpod` (o `riverpod` según enfoque), `go_router`, `dio`, `flutter_secure_storage`, `local_auth`, `uuid`. Las versiones exactas deben elegirse por compatibilidad con el SDK (`^3.13.7` observado) y documentarse.

## Pendientes inmediatos

1. Actualizar `pubspec.yaml` con dependencias obligatorias y ejecutar resolución.
2. Crear `app_router.dart` y migrar `main.dart` a usar `MaterialApp.router`.
3. Implementar cliente Dio con interceptores y almacenamiento seguro.
4. Definir providers base de sesión y manejo de errores. 
