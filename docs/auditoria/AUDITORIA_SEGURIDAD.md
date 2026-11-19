# AUDITORÍA INTEGRAL DE SEGURIDAD FINANCIERA — BANKOS (FASE 6)

**Proyecto:** BankOS  
**Fecha:** 2026-11-19  
**Autor:** Senior Software Architect & Security Auditor  
**Nivel de Exigencia:** Estándar Bancario / OWASP Top 10 API Security  

---

## 1. Resumen Ejecutivo de Seguridad

BankOS maneja fondos financieros y transacciones entre múltiples entidades bancarias en una arquitectura *Multi-Tenant*. La seguridad se ha auditado bajo 8 dimensiones críticas, confirmando un nivel de madurez elevado y estableciendo las pautas obligatorias para el paso a producción.

---

## 2. Evaluación Dimensional de Seguridad

### 2.1 Aislamiento Multi-Inquilino (Multi-Tenancy Isolation) — ESTADO: VERIFICADO
- **Mecanismo:** Cada token JWT contiene el claim firmado `tenant_code` y `tenant_id`.
- **Filtro de Seguridad:** El backend intercepta cada petición y fija el contexto en `TenantContextHolder` (ThreadLocal).
- **Protección a Nivel SQL:** Los repositorios JPA aplican cláusulas `WHERE tenant_id = :tenantId` en todas las consultas de selección, actualización y borrado.
- **Prueba de Aislamiento:** Verificada en `TransactionApiIntegrationTest` donde una consulta con token del Tenant B hacia una cuenta del Tenant A retorna inmediatamente `404 NOT FOUND` (`ACCOUNT_NOT_FOUND`), imposibilitando el sondeo de existencia (*tenant probing*).

### 2.2 Integridad Contable y Prevención de Deadlocks — ESTADO: VERIFICADO
- **Principio de Doble Partida:** Ninguna cuenta se acredita o debita de forma aislada. Cada movimiento genera al menos dos asientos contables cuya suma neta es exactamente cero (`DEBIT` + `CREDIT` = 0).
- **Bloqueo Pesimista Ordenado (`PESSIMISTIC_WRITE`):** En transferencias entre cuentas A y B, los registros se bloquean en la base de datos ordenados lexicográficamente por UUID (`min(idA, idB)` primero, luego `max(idA, idB)`). Esto previene matemáticamente los bloqueos mutuos (*deadlocks*) en transacciones concurrentes cruzadas (A→B y B→A simultáneas).
- **Idempotencia Estricta:** Las transacciones financieras requieren la cabecera `Idempotency-Key` (UUID v4). El backend almacena un hash criptográfico SHA-256 del cuerpo de la petición. Si se recibe la misma llave con el mismo cuerpo, se devuelve la respuesta en caché sin reprocesar fondos; si se recibe la misma llave con diferente cuerpo, se rechaza inmediatamente con `409 CONFLICT`.

### 2.3 Autenticación y Gestión de Sesiones — ESTADO: VERIFICADO
- **Backend:** Spring Security 6 con OAuth2 Resource Server y Nimbus JWT. Las contraseñas se almacenan mediante hash BCrypt con factor de costo 12.
- **Frontend Móvil:** Almacenamiento seguro cifrado mediante `FlutterSecureStorage`:
  - En Android: Cifrado por hardware mediante Android Keystore / EncryptedSharedPreferences.
  - En iOS: Cifrado en Apple Keychain con clase de accesibilidad segura.
  - No se almacenan tokens ni secretos en `SharedPreferences` plano ni en SQLite sin cifrar.
  - Control de caducidad con margen de seguridad (*skew*) de 30 segundos antes de invocar la API.

### 2.4 Control de Acceso Basado en Roles (RBAC) — ESTADO: VERIFICADO
- Los roles definidos (`PLATFORM_ADMIN`, `TENANT_ADMIN`, `OPERATOR`, `AUDITOR`) están protegidos mediante anotaciones `@PreAuthorize` en los controladores de Spring Boot.
- El frontend valida los permisos antes de renderizar opciones administrativas, capturando respuestas `403 FORBIDDEN` de manera segura sin exponer trazas de servidor.

### 2.5 Inyección SQL y Validación de Entradas — ESTADO: VERIFICADO
- El 100% de las consultas utilizan Spring Data JPA con parámetros ligados tipados. Cero consultas mediante concatenación de cadenas (`String formatting`).
- Validación estricta de payloads con Bean Validation (`@Valid`, `@NotBlank`, `@Positive`, `@DecimalMin`, expresiones regulares de formato).

### 2.6 Protección de Datos en Tránsito y CORS — ESTADO: RECOMENDACIÓN PRODUCCIÓN
- En desarrollo: CORS habilitado para pruebas locales.
- **Obligatorio en Producción:** Restringir orígenes permitidos en `SecurityConfig.java` a los dominios del cliente web y exigir TLS 1.3 con certificados válidos.

### 2.7 Manejo de Secretos — ESTADO: MITIGADO
- En entornos locales de prueba se emplea una clave simétrica de desarrollo en `application-dev.yml`.
- **Obligatorio en Producción:** La variable `JWT_SECRET` debe ser inyectada dinámicamente mediante variables de entorno seguras (Docker Secrets, Vault o AWS Secrets Manager), impidiendo que resida en el repositorio Git.
