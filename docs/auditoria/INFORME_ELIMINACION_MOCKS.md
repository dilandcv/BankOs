# INFORME DE ERRADICACIÓN DE MOCKS EN TIEMPO DE EJECUCIÓN (FASE 4)

**Proyecto:** BankOS  
**Fecha:** 2026-11-19  
**Autor:** Senior Software Architect  
**Alcance:** Frontend Flutter (`mobile/`) y Backend Spring Boot (`backend/`)  

---

## 1. Resumen de la Intervención

En estricto cumplimiento de las directrices de la **Fase 4**:
- Se erradicó el 100% de los datos falsos, listas hardcodeadas y servicios simulados en tiempo de ejecución.
- Ninguna pantalla ni repositorio utiliza información simulada para aparentar funcionalidad.
- Se mantiene una separación categórica entre código de producción (0% mocks) y herramientas de prueba automatizadas (mocks permitidos en testing unitario aislado).

---

## 2. Inventario y Estado de Mocks Detectados

| Componente Original | Ubicación | Naturaleza del Mock | Acción Realizada | Evidencia de Verificación |
|---|---|---|---|---|
| `MockData.dart` | `mobile/lib/shared/constants/mock_data.dart` | Saldos inventados (`$12,450.00`), usuario "María González", cuentas falsas (`acc-1`, `acc-2`, `acc-3`) y 4 movimientos simulados. | **ELIMINADO FÍSICAMENTE** en commit `a5b5f5b`. | Archivo inexistente. Búsqueda recursiva: 0 coincidencias. |
| `LoginScreen` | `mobile/lib/features/auth/login_screen.dart` | Bypass de autenticación con navegación directa a `/dashboard`. | **REEMPLAZADO** por `AuthRepository.login()` con envío real de `tenant_code`, `email`, `password`. | Pantalla conectada a `authNotifierProvider` y API real. |
| `DashboardScreen` | `mobile/lib/features/dashboard/dashboard_screen.dart` | Lectura de balances de `MockData.totalBalance`. | **REEMPLAZADO** por `accountsProvider` y agregación reactiva de cuentas reales. | Consume DTO `AccountResponse` de PostgreSQL. |
| `AccountsScreen` | `mobile/lib/features/accounts/accounts_screen.dart` | Listado de cuentas fijas en memoria. | **REEMPLAZADO** por `AccountsRepository.list()`. | Petición HTTP `GET /api/v1/accounts` mediante Dio. |
| `TransactionsScreen` | `mobile/lib/features/transactions/transactions_screen.dart` | 4 transacciones quemadas en código. | **REEMPLAZADO** por `TransactionsRepository.history()`. | Petición HTTP `GET /api/v1/transactions` con paginación real. |
| `TransferPreviewScreen` | `mobile/lib/features/transactions/transfer_preview_screen.dart` | Valores estáticos ($250.00, comisión $1.50). | **REEMPLAZADO** por `TransactionsRepository.previewTransfer()`. | Invocación `POST /api/v1/transactions/transfers/preview`. |
| `Backend Repositories` | `backend/src/main/.../repository` | Verificación de persistencia en memoria. | **CONFIRMADO 100% REAL**. | Todas las operaciones persisten en PostgreSQL 16 con Flyway. |

---

## 3. Delimitación con Mocks de Pruebas (Testing)

Siguiendo la sección 7.4 de las especificaciones:
- Los únicos mocks conservados residen estrictamente en `mobile/test/` (usando `MockClient` de Dio y `mockito`) para pruebas unitarias aisladas de parseo JSON y manejo de errores HTTP.
- Ninguno de estos mocks se importa ni se ejecuta en el árbol de producción (`mobile/lib/`).

---

## 4. Conclusión de la Fase 4

El sistema BankOS ha alcanzado un estado de **0.0% mocks en tiempo de ejecución**. La aplicación opera exclusivamente sobre modelos de dominio, DTOs y llamadas HTTP reales.
