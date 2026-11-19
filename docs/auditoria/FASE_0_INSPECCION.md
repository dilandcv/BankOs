# FASE 0 — INSPECCIÓN Y PROTECCIÓN DEL PROYECTO (ACTUALIZADA POST-PULL)

**Fecha de ejecución:** 2026-11-18  
**Rama activa:** `develop` (HEAD en `f19949c`, sincronizada con `origin/develop`)  
**Rol del auditor:** Senior Software Architect, Senior Flutter Developer y Senior Java Backend Engineer  
**Estado:** Inspección actualizada tras `git pull` de los cambios desarrollados en el otro portátil.  

---

## 1. Estructura General del Repositorio

El proyecto `BankOS` reside en el monorepo Git ubicado en `/home/dylan/Escritorio/BankOs`:

```text
BankOS/
├── .git/                               # Repositorio Git centralizado (rama develop)
├── .github/                            # Plantillas de PR de GitHub
├── .gitignore                          # Exclusiones de Git a nivel raíz
├── backend/                            # Aplicación Java 21 + Spring Boot 3.5.0
│   ├── .dockerignore
│   ├── .env.example
│   ├── Dockerfile                      # Multi-stage build (Maven 3.9 + Temurin JRE 21)
│   ├── README.md                       # Documentación técnica del backend
│   ├── docker-compose.yml              # Orquestación de backend, postgres y redis
│   ├── docs/                           # Documentación técnica del backend
│   ├── pom.xml                         # Descriptor Maven
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/bankos/        # Monolito modular (10 módulos + común)
│   │   │   └── resources/              # Configuración YAML y migraciones Flyway
│   │   └── test/                       # Tests unitarios e integración Testcontainers
│   └── target/                         # Artefacto bankos-backend-0.1.0-SNAPSHOT.jar
├── docs/                               # Documentación arquitectónica original y auditoría
│   ├── auditoria/                      # Entregables oficiales de auditoría (Fases 0 y 1)
│   ├── api/                            # Contratos, errores y visión general
│   ├── architecture/                   # Diagramas, modelo multi-banco y diseño DB
│   ├── development/                    # Estándares de código, workflow Git, equipo
│   ├── quality/                        # Criterios de aceptación, DoD, testing
│   └── security/                       # Autenticación, multitenancy, seguridad financiera
└── mobile/                             # Aplicación móvil Flutter + Dart (con capa de red)
    ├── .gitignore
    ├── .metadata
    ├── README.md
    ├── analysis_options.yaml           # Reglas de linter (flutter_lints 6.0.0)
    ├── android/, ios/, linux/, macos/, web/, windows/  # Plataformas host
    ├── lib/                            # Código fuente Dart (Arquitectura por features)
    │   ├── app.dart
    │   ├── core/
    │   │   ├── config/api_config.dart
    │   │   ├── network/                # ApiClient, ApiEndpoints, ApiResponse, IdempotencyKey
    │   │   ├── router/app_router.dart
    │   │   ├── security/               # BiometricService
    │   │   ├── session/auth_session.dart
    │   │   ├── storage/secure_session_store.dart
    │   │   └── theme/tenant_theme.dart
    │   ├── features/                   # accounts, admin, audit, auth, customers, dashboard, settings, tenants, transactions, users, webhooks
    │   ├── main.dart
    │   └── shared/                     # Widgets compartidos, selectores, formateadores
    ├── test/                           # 9 suites de pruebas unitarias y de integración
    │   ├── core/                       # Tests de network, session, storage
    │   ├── features/                   # Tests de integración, multi-banco, permisos admin
    │   ├── fixtures/                   # JSONs de prueba (login, me, accounts, preview)
    │   └── helpers/fake_adapter.dart   # Mock HttpAdapter para pruebas sin servidor
    ├── pubspec.lock
    └── pubspec.yaml                    # Dependencias Flutter actualizadas con Dio y SecureStorage
```

---

## 2. Tecnologías y Versiones Utilizadas

| Componente | Tecnología | Versión Detectada | Notas de Entorno |
|---|---|---|---|
| **Sistema Operativo** | Linux Mint 22 (Linux x86_64) | Kernel 6.8.0 | Entorno local |
| **Backend Runtime** | Java OpenJDK (Eclipse Temurin) | Java 21 (21.0.12.1 en Docker) | Compilación y ejecución mediante contenedor `maven:3.9-eclipse-temurin-21` |
| **Backend Framework** | Spring Boot | 3.5.0 | Monolito modular |
| **Compilador Backend** | Apache Maven | 3.9 (en contenedor Docker) | Build verificado exitoso |
| **Frontend Framework** | Flutter SDK | 3.47.9 (channel stable) | Ubicado en `/home/dylan/Descargas/flutter/bin/flutter` |
| **Frontend Runtime** | Dart SDK | 3.13.7 (stable) | Binario en `/usr/bin/dart` y en bundle de Flutter |
| **Base de Datos** | PostgreSQL | 16-alpine (Docker) / 16 en host | Migraciones gestionadas con Flyway 10.x |
| **Caché / Broker** | Redis | 7-alpine (Docker) | Configurado en `application.yml` y healthcheck |
| **Contenedores** | Docker Engine & Compose | Docker 29.9.2, Compose v5.6.1 | Daemon funcional en `/var/run/docker.sock` |
| **Documentación API** | springdoc-openapi | 2.8.9 | Expone `/v3/api-docs` y `/swagger-ui.html` |
| **Cliente HTTP Móvil**| Dio | 5.11.1 | Incorporado con interceptores de correlación, auth e idempotencia |
| **Almacenamiento Móvil**| Flutter Secure Storage | 11.2.0 | Incorporado para persistencia de tokens JWT multi-tenant |

---

## 3. Estado de Dependencias Tras el `git pull`

### 3.1 Flutter (`mobile/pubspec.yaml`)
El código traído del otro portátil resolvió las principales carencias de librerías identificadas previamente:
- `dio: ^5.11.1` (Cliente HTTP profesional).
- `flutter_secure_storage: ^11.2.0` (Almacenamiento seguro de tokens y credenciales).
- `uuid: ^4.6.0` (Generación de llaves `Idempotency-Key` y `X-Correlation-ID`).
- `decimal: ^3.2.6` (Manejo de precisión monetaria).
- `local_auth: ^3.0.2` (Soporte biométrico).
- `flutter_riverpod: ^2.6.1` y `go_router: ^14.8.1`.

### 3.2 Spring Boot (`backend/pom.xml`)
Se mantiene sin alteraciones: Spring Boot 3.5.0, Spring Security 6, OAuth2 Resource Server con Nimbus, Spring Data JPA, Flyway, PostgreSQL, Redis, Testcontainers y JaCoCo.

---

## 4. Estado de Git, Ramas y Remotos Tras `git pull`

- **Rama local actual:** `develop` (actualizada mediante fast-forward a `f19949c`, a la par con `origin/develop`).
- **Historial completo de commits:**
  1. `006fa13`: *chore: initial commit with project docs and structure*
  2. `927a115`: *feat(backend): implement multi-tenant banking backend*
  3. `a5b5f5b`: *feat(mobile): integrate Flutter mobile app with multi-tenant backend API* (eliminó `MockData.dart`, incorporó Dio, modelos y repositorios).
  4. `d49167f`: *style(mobile): use dynamic tenant theme colors across screens and widgets*
  5. `f19949c`: *feat(auth): implement centralized authentication, master dashboard hub, and fast account switcher* (HEAD actual).
- **Ramas remotas disponibles:**
  - `origin/develop` (HEAD remoto, apunta a `f19949c`)
  - `origin/feature/mobile-backend-integration` (apunta a `f19949c`)
  - `origin/feature/backend-implementation` (apunta a `927a115`)

---

## 5. Localización de OpenAPI Tras `git pull`

- **Archivo estático `openapi.yaml`:** **Continúa sin existir físicamente en disco**.
- El frontend implementó `mobile/lib/core/network/api_endpoints.dart` mapeando los endpoints manualmente contra los contratos documentados, pero la ausencia de un `openapi.yaml` versionado impide una generación formal de contratos.

---

## 6. Pruebas Automatizadas y Estado de Compilación

### 6.1 Backend (Java / Spring Boot)
- Compilación `mvn test-compile`: **BUILD SUCCESS**.
- Pruebas automatizadas: **7 pruebas pasando (100% éxito)** (`MoneyUtilsTest` y `TransactionApiIntegrationTest` con Testcontainers).

### 6.2 Frontend (Flutter)
- Se ejecutó `flutter test` sobre las 9 suites de prueba en `mobile/test/`.
- **Resultado:**
  - **17 pruebas unitarias PASANDO:**
    - `auth_session_test.dart` (2 tests pasando)
    - `api_client_test.dart` (6 tests pasando)
    - `api_response_test.dart` (4 tests pasando)
    - `secure_session_store_test.dart` (5 tests pasando)
  - **5 suites de prueba FALLANDO POR ERRORES DE COMPILACIÓN:**
    1. `mobile/lib/features/auth/data/auth_repository.dart:153`: Método `delete` no definido en `ApiClient`.
    2. `mobile/lib/features/auth/data/auth_repository.dart:160`: Método `patch` no definido en `ApiClient`.
    3. `mobile/lib/shared/constants/app_colors.dart`: Las vistas referencian `AppColors.error`, pero la clase solo define `AppColors.danger`.
    4. `mobile/test/features/master_auth_and_switcher_test.dart:169`: `Couldn't find constructor 'Color'` (falta importar `dart:ui` o `material.dart`).

---

## 7. Diagnóstico de la Fase 0 Tras `git pull`

1. El trabajo realizado en el otro portátil avanzó en la dirección correcta: **eliminó `MockData.dart`**, estructuró la arquitectura de repositorios en Flutter y añadió una suite de pruebas con fixtures.
2. Sin embargo, los últimos commits (`f19949c` y `d49167f`) introdujeron **roturas de compilación en Flutter** (`ApiClient` incompleto y colores inexistentes).
3. La aplicación aún se encuentra en un monorepo y no se ha exportado el archivo canónico `openapi.yaml`.
