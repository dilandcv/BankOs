# BankOS — Aplicación Móvil y Web (`BanckOs-mobile`)

Cliente multiplataforma de **BankOS** para **Android, iOS, Web y Desktop**, desarrollado con **Flutter (Dart 3)** y **Riverpod**.

La aplicación está completamente integrada con los servicios reales del backend Spring Boot (`/api/v1`). **Cero mocks en tiempo de ejecución:** todas las pantallas consumen la API real, gestionan tokens por institución, aplican el tema corporativo dinámico de cada banco y soportan operaciones financieras seguras con idempotencia.

**Repositorios del Ecosistema:**
- Mobile/Frontend (Este repositorio): [BanckOs-mobile](https://github.com/dilandcv/BanckOs-mobile)
- Backend: [BankOs-backend](https://github.com/dilandcv/BankOs-backend)
- Contratos Oficiales: [BankOs-contracts](https://github.com/dilandcv/BankOs-contracts)

---

## 1. ¿Cuál repositorio debo clonar si quiero probar el proyecto completo?

Para probar el proyecto completo funcionando de extremo a extremo:

1. **Debes clonar primero [BankOs-backend](https://github.com/dilandcv/BankOs-backend.git)** para levantar los servicios del backend, la base de datos PostgreSQL y Redis con Docker Compose.
2. **Debes clonar este repositorio (`BanckOs-mobile`)** para ejecutar la aplicación visual en tu navegador web, emulador de Android o simulador de iOS.

### ¿Para qué es el tercer repositorio (`BankOs-contracts`)?
El repositorio `BankOs-contracts` almacena el contrato canónico **OpenAPI 3.1.0** (`openapi.yaml`). Es la **única fuente de verdad** que define los endpoints, estructuras DTO y cabeceras que este cliente consume. Este repositorio móvil incluye una prueba automatizada (`contract_parity_test.dart`) que calcula el hash SHA-256 del contrato local y verifica que coincida exactamente con la versión canónica (`f454d326...`). No necesitas clonar `contracts` a menos que desees proponer cambios a la especificación de la API.

---

## 2. Guía de Ejecución Rápida del Sistema Completo

### Paso 1: Levantar el Backend
Antes de lanzar Flutter, asegúrate de que el backend esté arriba:
```bash
git clone https://github.com/dilandcv/BankOs-backend.git
cd BankOs-backend
cp .env.example .env
docker compose up --build -d
```
Verifica que responda: `curl http://localhost:8080/actuator/health` -> `{"status":"UP"}`.

### Paso 2: Ejecutar el Cliente Flutter

Desde este repositorio (`BanckOs-mobile`):

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar según la plataforma de tu preferencia:

# Opción A: En Google Chrome (Recomendado para pruebas rápidas)
flutter run -d chrome

# Opción B: En Emulador Android
flutter run

# Opción C: En Simulador iOS (macOS)
flutter run -d "iPhone 15 Simulator"
```

### Configuración Automática de URLs por Plataforma

`lib/core/config/api_config.dart` resuelve automáticamente la URL base del backend:

| Plataforma | Host y Puerto por Defecto |
|---|---|
| **Flutter Web** | `http://localhost:8080/api/v1` |
| **iOS Simulator** | `http://localhost:8080/api/v1` |
| **Android Emulator** | `http://10.0.2.2:8080/api/v1` *(enrutamiento especial de Android hacia el host)* |
| **Dispositivo Físico** | Especificar la IP de tu PC: `flutter run --dart-define=API_BASE_URL=http://192.168.1.X:8080` |

---

## 3. Credenciales Demo para Pruebas

Usa las siguientes credenciales precargadas en la base de datos:

**Contraseña universal:** `Admin123!`

- **Institución / Tenant:** `BANCO_HORIZONTE`
- **Correo:** `admin@horizonte.com`
- **Contraseña:** `Admin123!`

*(Otras instituciones disponibles para probar el cambio de banco y tematización: `NEQUI`, `DAVIPLATA`, `PAYPAL`, `BANCOLOMBIA`, `NU`, `PLATFORM`).*

---

## 4. Arquitectura y Tecnologías del Frontend

La aplicación utiliza arquitectura **Feature-First**:

```
lib/
├── core/
│   ├── config/api_config.dart             # Resolución automática de host
│   ├── network/api_client.dart            # Dio encapsulado: interceptores JWT, correlación, idempotencia
│   ├── session/auth_session.dart          # Estado de usuario, tenant y permisos por rol
│   ├── storage/secure_session_store.dart  # Persistencia de tokens en flutter_secure_storage
│   ├── router/app_router.dart             # GoRouter con guards de autenticación y RBAC
│   └── providers.dart                     # Providers globales de Riverpod
├── features/
│   ├── authentication/                    # Login por banco y recuperación de sesión
│   ├── dashboard/                         # Dashboard con temas dinámicos según el banco
│   ├── accounts/                          # Cuentas bancarias y saldos en tiempo real
│   ├── transactions/                      # Historial, depósitos, retiros y transferencias idempotentes
│   ├── tenants/                           # Selector multi-banco y switch de sesión instantáneo
│   ├── users/ customers/ settings/        # Módulos de gestión administrativa según rol
│   └── audit/ webhooks/                   # Consulta de auditoría y monitoreo outbox
└── shared/                                # Paleta de colores, tipografía y widgets reutilizables
```

### Principios de Seguridad y Manejo Financiero
- **Tokens seguros:** Los JWTs se almacenan exclusivamente en `flutter_secure_storage`, nunca en SharedPreferences ni en texto plano.
- **Precisión monetaria:** Prohibido el uso de `double` para cálculos o montos de dinero; se manejan cadenas y aritmética decimal exacta.
- **Idempotencia:** Cada transacción genera un UUID único que se envía en la cabecera `Idempotency-Key`, permitiendo reintentos seguros sin duplicar transferencias.
- **RBAC (Role-Based Access Control):** Las pantallas y opciones se habilitan o bloquean de acuerdo a los roles retornados por el JWT (`TENANT_ADMIN`, `OPERATOR`, `AUDITOR`, `PLATFORM_ADMIN`).

---

## 5. Calidad y Pruebas Automatizadas

La aplicación cuenta con cobertura de pruebas unitarias, de integración y de paridad de contratos:

```bash
# Análisis estático de código (0 errores)
flutter analyze

# Suite completa de pruebas automatizadas (51 tests)
flutter test
```

### Pruebas de Paridad de Contrato
- `test/core/network/contract_parity_test.dart`: Lee el archivo `openapi.yaml` local, calcula su SHA-256 y verifica que coincida con `f454d326...`. Si alguien altera el contrato localmente sin actualizar la fuente oficial, los tests fallan inmediatamente.

---

## 6. Compilación para Producción

```bash
# Compilar versión Web
flutter build web --release --no-wasm-dry-run

# Compilar versión APK para Android
flutter build apk --release
```
