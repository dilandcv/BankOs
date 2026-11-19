# AUDITORÍA DEL CONTRATO OPENAPI Y DISCREPANCIAS

**Fecha:** 2026-11-18  
**Rol del auditor:** Senior Software Architect  
**Estado:** Inspección completa del contrato y matriz de trazabilidad  

---

## 1. Situación Actual de OpenAPI

El contrato OpenAPI es el pilar central solicitado para gobernar la comunicación entre Flutter y Spring Boot. Sin embargo, la inspección técnica de la Fase 0 reveló la siguiente realidad:

1. **Inexistencia de archivo estático `openapi.yaml`:**
   - En el sistema de archivos del proyecto **no existe** ningún archivo físico denominado `openapi.yaml` ni `openapi.json`.
   - La especificación se genera exclusivamente en **tiempo de ejecución** dentro del backend mediante la librería `springdoc-openapi-starter-webmvc-ui:2.8.9` (en `/v3/api-docs` y `/swagger-ui.html`).
2. **Divergencia en la documentación estática de contratos:**
   - Existen dos archivos Markdown que describen los contratos de la API en el repositorio:
     - `docs/api/api-contracts.md` (creado en el commit inicial `006fa13`).
     - `backend/docs/api/api-contracts.md` (actualizado en el commit `927a115`).
   - El archivo en `backend/docs/api/api-contracts.md` refleja fielmente los controladores y DTOs de Spring Boot, mientras que `docs/api/api-contracts.md` quedó desactualizado respecto a códigos de error y respuestas de auditoría.
3. **Consumo nulo en Frontend:**
   - Flutter **no consume** ningún endpoint definido en OpenAPI. Todas las vistas operan desconectadas y alimentadas por `MockData.dart`.

---

## 2. Matriz de Trazabilidad: OpenAPI vs Backend vs Flutter

| # | Método | Ruta del Endpoint | Definido en Contrato / SpringDoc | Implementado en Backend | Consumido en Flutter | Estado Global |
|---|:---:|---|:---:|:---:|:---:|---|
| 1 | `POST` | `/api/v1/auth/login` | SÍ | SÍ (`AuthController`) | **NO** (Navega ciego) | **DISCREPANCIA FRONTEND** |
| 2 | `GET` | `/api/v1/auth/me` | SÍ | SÍ (`AuthController`) | **NO** (Usa mock) | **DISCREPANCIA FRONTEND** |
| 3 | `POST` | `/api/v1/tenants` | SÍ | SÍ (`TenantController`) | **NO** (N/A móvil cliente) | **OK (Solo Backend)** |
| 4 | `GET` | `/api/v1/tenants` | SÍ | SÍ (`TenantController`) | **NO** (Falta selector tenant) | **PENDIENTE FRONTEND** |
| 5 | `GET` | `/api/v1/tenants/{id}` | SÍ | SÍ (`TenantController`) | **NO** | **OK (Solo Backend)** |
| 6 | `POST` | `/api/v1/users` | SÍ | SÍ (`UserController`) | **NO** (Admin) | **OK (Solo Backend)** |
| 7 | `GET` | `/api/v1/users` | SÍ | SÍ (`UserController`) | **NO** (Admin) | **OK (Solo Backend)** |
| 8 | `GET` | `/api/v1/users/{id}` | SÍ | SÍ (`UserController`) | **NO** (Admin) | **OK (Solo Backend)** |
| 9 | `POST` | `/api/v1/customers` | SÍ | SÍ (`CustomerController`) | **NO** (Admin) | **OK (Solo Backend)** |
| 10 | `GET` | `/api/v1/customers` | SÍ | SÍ (`CustomerController`) | **NO** (Admin) | **OK (Solo Backend)** |
| 11 | `GET` | `/api/v1/customers/{id}` | SÍ | SÍ (`CustomerController`) | **NO** (Admin) | **OK (Solo Backend)** |
| 12 | `POST` | `/api/v1/accounts` | SÍ | SÍ (`AccountController`) | **NO** (Admin) | **OK (Solo Backend)** |
| 13 | `GET` | `/api/v1/accounts` | SÍ | SÍ (`AccountController`) | **NO** (Usa mock) | **DISCREPANCIA FRONTEND** |
| 14 | `GET` | `/api/v1/accounts/all` | SÍ | SÍ (`AccountController`) | **NO** (Usa mock) | **PENDIENTE FRONTEND** |
| 15 | `GET` | `/api/v1/accounts/{id}` | SÍ | SÍ (`AccountController`) | **NO** (Usa mock 'acc-1') | **DISCREPANCIA FRONTEND** |
| 16 | `POST` | `/api/v1/transactions/deposits` | SÍ | SÍ (`TransactionController`) | **NO** (Formulario mock) | **DISCREPANCIA FRONTEND** |
| 17 | `POST` | `/api/v1/transactions/withdrawals` | SÍ | SÍ (`TransactionController`) | **NO** (Formulario mock) | **DISCREPANCIA FRONTEND** |
| 18 | `POST` | `/api/v1/transactions/transfers` | SÍ | SÍ (`TransactionController`) | **NO** (Confirmar diseño) | **DISCREPANCIA FRONTEND** |
| 19 | `POST` | `/api/v1/transactions/transfers/preview` | SÍ | SÍ (`TransactionController`) | **NO** (Valores duros) | **DISCREPANCIA FRONTEND** |
| 20 | `GET` | `/api/v1/transactions` | SÍ | SÍ (`TransactionController`) | **NO** (Usa mock) | **DISCREPANCIA FRONTEND** |
| 21 | `GET` | `/api/v1/transactions/{id}` | SÍ | SÍ (`TransactionController`) | **NO** | **PENDIENTE FRONTEND** |
| 22 | `GET` | `/api/v1/settings` | SÍ | SÍ (`SettingsController`) | **NO** | **OK (Solo Backend)** |
| 23 | `PUT` | `/api/v1/settings` | SÍ | SÍ (`SettingsController`) | **NO** (Admin) | **OK (Solo Backend)** |
| 24 | `GET` | `/api/v1/settings/exchange-rates` | SÍ | SÍ (`SettingsController`) | **NO** | **OK (Solo Backend)** |
| 25 | `GET` | `/api/v1/settings/exchange-rates/{id}` | SÍ | SÍ (`SettingsController`) | **NO** | **OK (Solo Backend)** |
| 26 | `POST` | `/api/v1/settings/exchange-rates` | SÍ | SÍ (`SettingsController`) | **NO** (Admin) | **OK (Solo Backend)** |
| 27 | `GET` | `/api/v1/audit-logs` | SÍ | SÍ (`AuditController`) | **NO** (Auditoría) | **OK (Solo Backend)** |
| 28 | `GET` | `/api/v1/audit-logs/{id}` | SÍ | SÍ (`AuditController`) | **NO** (Auditoría) | **OK (Solo Backend)** |
| 29 | `GET` | `/api/v1/webhooks` | SÍ | SÍ (`WebhookController`) | **NO** (Webhooks) | **OK (Solo Backend)** |
| 30 | `POST` | `/api/v1/webhooks` | SÍ | SÍ (`WebhookController`) | **NO** (Webhooks) | **OK (Solo Backend)** |
| 31 | `GET` | `/api/v1/webhooks/events` | SÍ | SÍ (`WebhookController`) | **NO** (Outbox) | **OK (Solo Backend)** |

---

## 3. Discrepancias Técnicas Específicas

### 3.1 Autenticación e Identidad Institucional (Multi-banco)
- **Contrato OpenAPI:** `POST /api/v1/auth/login` requiere obligatoriamente:
  ```json
  {
    "tenant_code": "BANCO_HORIZONTE",
    "email": "admin@horizonte.com",
    "password": "Admin123!"
  }
  ```
- **Implementación Flutter:** `LoginScreen.dart` solo tiene campos visuales para "Usuario" y "Contraseña". Carece de campo para `tenant_code`, rompiendo la arquitectura multi-institución.

### 3.2 Idempotencia en Operaciones Financieras
- **Contrato OpenAPI:** Todos los endpoints financieros (`/deposits`, `/withdrawals`, `/transfers`) exigen la cabecera HTTP:
  ```http
  Idempotency-Key: <UUID>
  ```
  Si la cabecera no se envía, el backend responde `400 IDEMPOTENCY_KEY_REQUIRED`.
- **Implementación Flutter:** La aplicación móvil no genera UUIDs de idempotencia ni tiene una capa de red que inyecte esta cabecera obligatoria.

### 3.3 Modelo de Cuentas y Saldos
- **Contrato OpenAPI:** Las cuentas se identifican mediante UUID (`id: "30000000-0000-0000-0000-000000000001"`), el saldo es un `NUMERIC(19,4)` serializado como string (`"8250.0000"`), y la divisa es de 3 caracteres (`"USD"`).
- **Implementación Flutter:** Utiliza identificadores de texto plano (`'acc-1'`) y strings con símbolos monetarios preformateados (`'\$ 8,250.00'`), lo que imposibilita cálculos numéricos y validaciones en la app.

### 3.4 Previsualización y Ejecución de Transferencias
- **Contrato OpenAPI:** `POST /api/v1/transactions/transfers/preview` calcula la tasa de cambio y comisión entre `source_account_id` y `target_account_id`. Luego, `POST /api/v1/transactions/transfers` ejecuta el debito/crédito.
- **Implementación Flutter:** `TransferPreviewScreen.dart` muestra datos quemados sin realizar la llamada de cálculo previo ni la llamada de confirmación.

---

## 4. Evaluación de Estrategia para la Gestión del Contrato OpenAPI

Dado que Frontend y Backend tendrán repositorios Git independientes, es indispensable acordar el mecanismo para gobernar el archivo `openapi.yaml`.

### Alternativa A: Repositorio Git Independiente para Contratos (`BankOS-Contracts`)
- **Descripción:** Un tercer repositorio Git que contiene exclusivamente `openapi.yaml`, esquemas JSON y documentación de contratos.
- **Ventajas:** Desacoplamiento total; ambos equipos (móvil y backend) dependen de un repositorio neutral; versionamiento semántico formal de la API.
- **Desventajas:** Complejidad operativa añadida para un proyecto de alcance académico/MVP; requiere gestionar 3 pipelines de CI/CD, sincronización y credenciales para 3 repositorios.

### Alternativa B: Backend como Fuente de Verdad y Publicación de Artefacto Verificado (Recomendada)
- **Descripción:** El backend Spring Boot es el originador oficial del contrato OpenAPI. Durante la compilación/verificación del backend (mediante plugin Maven `springdoc-openapi-maven-plugin` o test de exportación), se genera y versiona un archivo físico `backend/contracts/openapi.yaml`. Este archivo verificado se publica o se distribuye como versión canónica al repositorio de Flutter (`mobile/contracts/openapi.yaml`).
- **Ventajas:**
  - Garantiza que el contrato y el código Java en producción nunca diverjan (el contrato se valida contra los DTOs y validaciones reales de Spring Boot).
  - Máxima simplicidad operativa: se mantienen exactamente los 2 repositorios solicitados por el profesor (`mobile` y `backend`) sin sobrecarga de infraestructura.
  - El equipo frontend puede usar herramientas locales de generación de clientes Dart (`openapi-generator-cli` o clientes tipados manuales basados estrictamente en el archivo).

### Recomendación de la Auditoría:
Se recomienda adoptar la **Alternativa B**:
1. Generar y congelar el archivo físico `openapi.yaml` oficial desde la implementación validada del backend.
2. Colocarlo en la raíz del repositorio backend en `openapi.yaml`.
3. Proveer una copia verificada de este contrato oficial en el repositorio frontend en `mobile/openapi.yaml`.
4. Establecer en la documentación que **cualquier cambio en la API requiere autorización previa del comité técnico y actualización coordinada del contrato**.
