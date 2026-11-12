# Guía de inicio (Getting Started) — BankOS

> **Estado auditado:** El repositorio no contiene backend implementado, ni configuración de Docker/BD, ni dependencias frontend completas. Esta guía combina pasos **verificables** con pasos **objetivo/pendientes** claramente marcados.

## 1. Clonar el repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd BankOs
```

**Pendiente:** Confirmar URL remota y rama principal acordada por el equipo (`main`/`develop`). Actualmente la rama local observada es `master` sin commits.

## 2. Requisitos previos

| Herramienta | Objetivo | Estado en repo |
|---|---|---|
| Git | Control de versiones | Requerido |
| Java 21 | Backend Spring Boot | **Pendiente** (no hay proyecto Maven) |
| Maven 3.9+ (o wrapper) | Build backend | **Pendiente** |
| Flutter SDK (compatible con Dart ^3.13.7) | Frontend móvil | Proyecto existe en `mobile/` |
| Dart | Incluido con Flutter | `environment: sdk: ^3.13.7` en `pubspec.yaml` |
| Docker + Docker Compose | PostgreSQL/Redis/API/worker | **Pendiente** (no hay compose) |
| PostgreSQL | BD principal | **Pendiente** |
| Redis | Cache/idempotencia/soporte | **Pendiente** |

## 3. Instalar Java 21

Ejemplo (Ubuntu/Debian, verificar según distribución):
```bash
java -version
# Debe mostrar versión 21.x
```
Instalación orientativa:
```bash
sudo apt update
sudo apt install -y openjdk-21-jdk
```
> Ajustar al sistema operativo del desarrollador. **Pendiente:** Estandarizar distribución de JDK en el equipo.

## 4. Instalar Flutter y Dart

```bash
flutter --version
dart --version
flutter doctor
```
Asegurar un SDK de Flutter que soporte `Dart ^3.13.7` (según `mobile/pubspec.yaml`). Seguir la instalación oficial para Linux y configurar `PATH`.

## 5. Configurar Maven

```bash
mvn -version
```
- **Objetivo:** Proyecto Maven en `backend/` con Spring Boot 3.5.x.
- **Estado actual:** No existe `pom.xml`. **Pendiente:** Inicializar proyecto (Spring Initializr o estructura manual acordada) y, opcionalmente, agregar Maven Wrapper (`mvnw`).

## 6. Configurar variables de entorno

- **Objetivo:** Externalizar configuración (BD, Redis, JWT, puertos, CORS, etc.) mediante variables de entorno.
- **Estado actual:** No hay `.env` ni `.env.example` en el repositorio.
- **Recomendación (pendiente):** Crear `.env.example` en la raíz o por servicio con placeholders, **sin contraseñas reales**. Ejemplo de variables esperadas (propuesto):

```env
# Backend
SPRING_PROFILES_ACTIVE=dev
SERVER_PORT=8080
DB_HOST=localhost
DB_PORT=5432
DB_NAME=bankos
DB_USER=bankos_user
DB_PASSWORD=change_me
REDIS_HOST=localhost
REDIS_PORT=6379
JWT_SECRET=change_me
JWT_EXPIRATION_MS=3600000

# Frontend (ejemplo)
API_BASE_URL=http://localhost:8080/api/v1
```

> Nunca commitear `.env` con secretos reales.

## 7. Levantar PostgreSQL y Redis

**Objetivo (Docker Compose, pendiente):**
```bash
docker compose up -d postgres redis
docker compose ps
```
- **Estado actual:** No existe `docker-compose.yml`. No se pueden ejecutar estos comandos hasta que se defina la infraestructura.
- **Alternativa temporal (pendiente):** Instalar PostgreSQL/Redis localmente y configurar credenciales manualmente.

## 8. Ejecutar Spring Boot

**Objetivo:**
```bash
cd backend
mvn spring-boot:run
# o con wrapper (si existe): ./mvnw spring-boot:run
```
- **Estado actual:** No es posible ejecutar; `backend/` está vacío y no hay aplicación Spring Boot.
- **Verificación esperada:** API disponible en `http://localhost:8080` (o puerto configurado).

## 9. Ejecutar Flutter

Pasos verificables con el estado actual:
```bash
cd mobile
flutter pub get
flutter run
```
Para un dispositivo/emulador específico:
```bash
flutter devices
flutter run -d <device_id>
```
> **Nota:** La app actual muestra "Hello World" y no consume backend. Al agregar dependencias objetivo (Riverpod, GoRouter, Dio, etc.) se deberá ejecutar nuevamente `flutter pub get`.

## 10. Ejecutar pruebas

**Frontend (disponible parcialmente):**
```bash
cd mobile
flutter test
```
> Puede no haber pruebas significativas aún; el template incluye estructura de test por defecto de Flutter según generación.

**Backend (pendiente):**
```bash
cd backend
mvn test
```
> No disponible hasta inicializar el proyecto y agregar pruebas.

## 11. Swagger/OpenAPI

- **Estado actual:** No configurado.
- **Objetivo (propuesto):** Exponer documentación OpenAPI (ej. `/swagger-ui.html` o `/swagger-ui/index.html`) en entorno de desarrollo.
- **Pendiente:** Agregar dependencia/configuración (springdoc-openapi u otra) y documentar URL exacta.

## Solución de problemas comunes (pendiente de ampliar)

- **Flutter/Dart SDK incompatible:** Ajustar versión de Flutter para cumplir `^3.13.7` o acordar actualización del constraint.
- **Puertos en uso:** Cambiar puertos en configuración/compose.
- **Errores de conexión a BD/Redis:** Verificar contenedores, variables de entorno y red. 
