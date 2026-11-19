# ARQUITECTURA DE REPOSITORIOS INDEPENDIENTES — BANKOS

**Proyecto:** BankOS  
**Fecha:** 2026-11-19  
**Autor:** Senior Software Architect  
**Estado:** Fase 3 (Separación de Repositorios) Ejecutada  

---

## 1. Visión General de la Nueva Estructura

El monorepo original `BankOS` ha sido desacoplado con éxito en **tres repositorios Git completamente independientes**, garantizando que el equipo de frontend y el equipo de backend trabajen con autonomía absoluta, utilizando `contracts/openapi.yaml` como contrato oficial inquebrantable:

```
BankOs/ (Directorio contenedor y respaldo seguro)
│
├── contracts/               <-- Repositorio Git independiente (.git/)
│   ├── .git/
│   ├── openapi.yaml         (Contrato canónico oficial v1.0.0 - SHA-256 verificado)
│   ├── openapi.sha256       (Hash criptográfico de paridad)
│   ├── GOVERNANCE.md        (Protocolo estricto RFC para cambios)
│   ├── README.md            (Especificación del contrato)
│   └── scripts/
│       └── verify-parity.sh (Script de validación automática de paridad)
│
├── backend/                 <-- Repositorio Git independiente (.git/)
│   ├── .git/
│   ├── .gitignore           (Exclusivo Java/Maven/IntelliJ)
│   ├── pom.xml
│   ├── openapi.yaml         (Copia sincronizada bit a bit)
│   ├── openapi.sha256
│   ├── docker-compose.yml   (PostgreSQL 16 en 55432, Redis 7 y Backend)
│   ├── src/                 (Monolito modular con 10 módulos)
│   │   └── test/java/.../ContractParityTest.java (Gate de CI/CD que valida SHA-256)
│   └── README.md            (Guía de compilación, ejecución y tests)
│
├── mobile/                  <-- Repositorio Git independiente (.git/)
│   ├── .git/
│   ├── .gitignore           (Exclusivo Flutter/Dart/Android/iOS)
│   ├── pubspec.yaml
│   ├── openapi.yaml         (Copia sincronizada bit a bit)
│   ├── openapi.sha256
│   ├── lib/                 (Arquitectura multicapa con Dio y Riverpod)
│   ├── test/                (Suite de pruebas + contract_parity_test.dart)
│   └── README.md            (Guía de emulación, tests y configuración)
│
└── docs/                    <-- Documentación compartida y auditoría
    ├── auditoria/           (Informes oficiales de auditoría)
    ├── PLAN_TRABAJO.md      (Hoja de ruta)
    ├── PROGRESO.md          (Tablero de seguimiento)
    ├── CONTRATO_OPENAPI.md  (Gobernanza)
    └── ARQUITECTURA_REPOSITORIOS.md (Este documento)
```

---

## 2. Preservación del Historial Git

La separación se ejecutó mediante filtrado de subárbol (`git subtree split`), preservando los autores, marcas de tiempo y mensajes de commit originales de la rama `develop`:

### Historial de `backend` (`backend/.git`):
- `d1cdd14` - `feat(backend): add canonical openapi.yaml, checksum and contract parity test`
- `a89983b` - `feat(auth): implement centralized authentication, master dashboard hub, and fast account switcher`
- `943670c` - `feat(mobile): integrate Flutter mobile app with multi-tenant backend API`
- `49a3fef` - `feat(backend): implement multi-tenant banking backend`
- `61d602c` - `chore: initial commit with project docs and structure`

### Historial de `mobile` (`mobile/.git`):
- `af76bab` - `feat(mobile): add canonical openapi.yaml, checksum and contract parity test`
- `d9f312c` - `feat(auth): implement centralized authentication, master dashboard hub, and fast account switcher`
- `1f29cdc` - `style(mobile): use dynamic tenant theme colors across screens and widgets`
- `ecac956` - `feat(mobile): integrate Flutter mobile app with multi-tenant backend API`
- `b405dcf` - `chore: initial commit with project docs and structure`

### Historial de `contracts` (`contracts/.git`):
- `19f21e7` - `feat(contracts): init canonical openapi v1.0.0 contract and governance` (etiquetado como `v1.0.0`).

---

## 3. Garantía de Paridad y No-Divergencia de OpenAPI

Cada repositorio contiene el archivo `openapi.yaml` y su checksum `openapi.sha256`:
- **Hash Oficial:** `f454d326e4b4ba731db6c422241595fd1d90021277e18531afff90fa26336141`
- **En Backend:** La prueba `ContractParityTest.java` falla si el archivo difiere en un solo byte.
- **En Frontend:** La prueba `contract_parity_test.dart` falla si el archivo difiere en un solo byte.
- **Verificación cruzada:** El script `contracts/scripts/verify-parity.sh` valida la identidad instantáneamente:
  ```bash
  contracts/scripts/verify-parity.sh backend
  contracts/scripts/verify-parity.sh mobile
  ```

---

## 4. Guía Operativa para Desarrolladores

### 4.1 Ejecutar el Backend de Forma Independiente
```bash
cd backend

# Opción A: Levantar base de datos y Redis con Docker
docker compose up -d postgres redis

# Opción B: Ejecutar compilación y pruebas con Docker Maven
docker run --rm -v $(pwd):/workspace -w /workspace -v ~/.m2:/root/.m2 maven:3.9-eclipse-temurin-21 mvn test

# Opción C: Ejecutar el backend localmente con Spring Boot
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```
- Endpoint de salud: `http://localhost:8080/actuator/health`
- Swagger UI (en dev): `http://localhost:8080/swagger-ui.html`
- OpenAPI JSON: `http://localhost:8080/v3/api-docs`

### 4.2 Ejecutar el Frontend Móvil de Forma Independiente
```bash
cd mobile

# Instalar dependencias
flutter pub get

# Ejecutar pruebas automatizadas
flutter test

# Ejecutar en emulador o dispositivo
flutter run
```
- Por defecto, `ApiClient` apunta a `http://localhost:8080` (en emulador Android utilizar `10.0.2.2:8080`).

### 4.3 Ejecutar el Sistema Completo Integrado
1. En una terminal, levantar la infraestructura y el backend:
   ```bash
   cd backend
   docker compose up -d
   ```
2. En otra terminal, iniciar la aplicación Flutter:
   ```bash
   cd mobile
   flutter run -d chrome # o emulador Android
   ```

---

## 5. Repositorios Remotos Oficiales Configurados

Los tres repositorios se encuentran debidamente vinculados y sincronizados con GitHub:

| Repositorio | Rama por Defecto / Ramas | URL Remota Oficial | Estado de Sincronización |
|---|:---:|---|:---:|
| **Contratos (`contracts`)** | `main` (Tag `v1.0.0`) | `https://github.com/dilandcv/BankOs-contracts.git` | **SINCRONIZADO (`main`, `v1.0.0`)** |
| **Backend (`backend`)** | `develop`, `main` | `https://github.com/dilandcv/BankOs-backend.git` | **SINCRONIZADO (`develop`, `main`)** |
| **Frontend Móvil (`mobile`)** | `develop`, `main` | `https://github.com/dilandcv/BanckOs-mobile.git` | **SINCRONIZADO (`develop`, `main`)** |
