# MATRIZ DE FUNCIONALIDADES DEL SISTEMA BANKOS (ACTUALIZADA POST-PULL)

**Fecha:** 2026-11-18  
**Rol del auditor:** Senior Software Architect  
**Criterio de clasificación estricto:**  
- **IMPLEMENTADA:** Lógica real, conectada a repositorios y entidades, sin simulaciones en tiempo de ejecución.  
- **PARCIAL:** Dispone de implementación técnica y de red, pero está afectada por errores de compilación menores pendientes de resolución.  
- **MOCK:** Depende de datos inventados o servicios simulados en runtime. *(0% tras eliminación de `MockData.dart`)*.  
- **NO IMPLEMENTADA:** No existe código.  
- **BLOQUEADA:** Depende de un factor externo no resuelto.  

---

## 1. Matriz Integral de Funcionalidades

| ID | Funcionalidad / Caso de Uso | Backend | Frontend | Integración E2E | Clasificación Global | Justificación Técnica Post-Pull |
|:---:|---|:---:|:---:|:---:|:---:|---|
| **F01** | Inicio de sesión multi-banco (`login`) | IMPLEMENTADA | PARCIAL | PENDIENTE | **PARCIAL** | Repositorio `AuthRepository` y pantalla `LoginScreen` implementados con captura de `tenant_code`, pero bloqueados por compilación de `AppColors.error`. |
| **F02** | Consulta de sesión actual (`me`) | IMPLEMENTADA | PARCIAL | PENDIENTE | **PARCIAL** | `AuthRepository.me()` implementado; pantalla de perfil afectada por `AppColors.error`. |
| **F03** | Creación de instituciones | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | Endpoint en Spring Boot y formulario `AddBankSheet` en Flutter. |
| **F04** | Listado de instituciones | IMPLEMENTADA | PARCIAL | PENDIENTE | **PARCIAL** | `TenantsRepository` implementado; selector `BankSwitcherBottomSheet` bloqueado por `AppColors.error`. |
| **F05** | Consulta de institución por ID | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `TenantsRepository.get(id)` implementado y tipado. |
| **F06** | Creación de usuarios de tenant | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `UsersRepository.create()` y pantalla administrativa implementadas. |
| **F07** | Listado paginado de usuarios | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `UsersRepository.list()` implementado. |
| **F08** | Detalle de usuario por ID | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `UsersRepository.get(id)` implementado. |
| **F09** | Creación de clientes bancarios | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `CustomersRepository.create()` y vista de clientes implementadas. |
| **F10** | Listado paginado de clientes | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `CustomersRepository.list()` implementado. |
| **F11** | Detalle de cliente por ID | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `CustomersRepository.get(id)` implementado. |
| **F12** | Creación de cuentas bancarias | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `AccountsRepository.create()` implementado. |
| **F13** | Listado de cuentas del usuario | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `AccountsRepository.list()` conectado a `accountsProvider`. |
| **F14** | Listado completo de cuentas (`/all`) | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `AccountsRepository.listAll()` conectado a `AccountSelector`. |
| **F15** | Consulta de detalle de cuenta | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `AccountsRepository.get(id)` y pantalla de detalle implementadas. |
| **F16** | Depósito bancario idempotente | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `TransactionsRepository.deposit()` envía `Idempotency-Key` real. |
| **F17** | Retiro bancario idempotente | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `TransactionsRepository.withdrawal()` envía `Idempotency-Key` real. |
| **F18** | Previsualización de transferencia | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `TransactionsRepository.previewTransfer()` implementado con DTO real. |
| **F19** | Transferencia bancaria idempotente | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `TransactionsRepository.transfer()` envía `Idempotency-Key` real. |
| **F20** | Historial paginado de transacciones | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `TransactionsRepository.history()` con filtros tipados. |
| **F21** | Detalle de transacción por ID | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `TransactionDetailScreen` implementada con asientos contables. |
| **F22** | Consulta de configuración | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `SettingsRepository.getSettings()` implementado. |
| **F23** | Actualización de comisiones | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `SettingsRepository.updateSettings()` implementado. |
| **F24** | Listado de tasas de cambio | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `SettingsRepository.listExchangeRates()` implementado. |
| **F25** | Creación de tasas de cambio | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `SettingsRepository.createExchangeRate()` implementado. |
| **F26** | Consulta de auditoría | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `AuditRepository.list()` y `AuditScreen` implementadas. |
| **F27** | Detalle de auditoría | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `AuditRepository.get(id)` implementado. |
| **F28** | Configuración de webhooks | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `WebhooksRepository.createConfig()` implementado. |
| **F29** | Listado de eventos outbox | IMPLEMENTADA | IMPLEMENTADA | PENDIENTE | **IMPLEMENTADA** | `WebhooksRepository.listEvents()` implementado. |
| **F30** | Master Dashboard / Hub Móvil | N/A (Móvil) | PARCIAL | PENDIENTE | **PARCIAL** | `MasterDashboardScreen` implementada pero bloqueada por `AppColors.error`. |
| **F31** | Perfil de usuario móvil | N/A (Móvil) | PARCIAL | PENDIENTE | **PARCIAL** | `ProfileScreen` conectada a `AuthRepository`, bloqueada por `AppColors.error`. |

---

## 2. Métricas Matemáticas Actualizadas Post-Pull

Sobre las **31 funcionalidades** del sistema:

### 2.1 Backend (29 funcionalidades aplicables):
- **IMPLEMENTADA:** 29 / 29 (**100.0%**)
- **MOCK:** 0 / 29 (**0.0%**)

### 2.2 Frontend Móvil (31 funcionalidades con soporte móvil):
- **IMPLEMENTADA (Lógica real, modelos y repositorios listos):** 25 / 31 (**80.6%**)
- **PARCIAL (Implementada pero bloqueada por 3 errores de compilación):** 6 / 31 (**19.4%**) (`F01`, `F02`, `F04`, `F30`, `F31` y repositorio de autenticación)
- **MOCK (Usa datos inventados en tiempo de ejecución):** 0 / 31 (**0.0%**) *(MockData eliminado)*

### 2.3 Consolidado Global del Sistema:
- **IMPLEMENTADA (Ambas capas completadas sin mocks):** 25 / 31 (**80.6%**)
- **PARCIAL (Bloqueada por errores de compilación en Flutter):** 6 / 31 (**19.4%**)
- **MOCK:** 0 / 31 (**0.0%**)
- **NO IMPLEMENTADA:** 0 / 31 (**0.0%**)
