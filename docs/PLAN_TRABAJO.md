# PLAN DE TRABAJO — BANKOS (FASE 2 A FASE 8)

**Proyecto:** BankOS  
**Fecha:** 2026-11-18  
**Autor:** Senior Software Architect, Senior Flutter Developer y Senior Java Backend Engineer  
**Objetivo:** Planificación detallada para la separación de repositorios, garantía de fuente única para OpenAPI, erradicación de errores de compilación, verificación de integraciones reales y preparación para producción.

---

## Clasificación de Prioridades
- **P0 (Crítico):** Tareas bloqueantes que condicionan la integridad estructural, la compilación, la separación de repositorios o el contrato OpenAPI.
- **P1 (Alto):** Tareas de integración real, seguridad, infraestructura y pruebas automatizadas esenciales.
- **P2 (Medio):** Tareas de optimización, cobertura adicional de widgets y hardening secundario.
- **P3 (Bajo):** Documentación complementaria y refinamiento estético de guías.

---

## 1. FASE 2 — Planificación y Gobernanza de Contratos

### [T-01] Estructuración del Plan de Trabajo y Sistema de Seguimiento
- **Prioridad:** P0
- **Descripción:** Definición y desglose de todas las tareas, dependencias, riesgos y criterios de aceptación en `docs/PLAN_TRABAJO.md` y activación del tablero de estados en `docs/PROGRESO.md`.
- **Objetivo:** Disponer de una hoja de ruta auditable y transparente para la ejecución controlada del proyecto.
- **Módulos afectados:** `docs/`
- **Dependencias:** Fases 0 y 1 aprobadas por el usuario.
- **Riesgo:** Bajo.
- **Criterios de Aceptación:** Existencia de `docs/PLAN_TRABAJO.md` y `docs/PROGRESO.md` con todas las tareas clasificadas (P0-P3).
- **Pruebas Necesarias:** Validación de consistencia cruzada de enlaces y dependencias.
- **Estado:** EN PROGRESO.

### [T-02] Diseño de Arquitectura y Gobernanza del Contrato Único OpenAPI
- **Prioridad:** P0
- **Descripción:** Definir la arquitectura para que `openapi.yaml` sea una **única fuente inquebrantable de verdad**, sin archivos duplicados que puedan divergir, evaluando el repositorio independiente `contracts` vinculado mediante Git Submodule o artefacto versionado con hash de integridad SHA-256.
- **Objetivo:** Garantizar que frontend y backend consuman exactamente el mismo contrato y prohibir modificaciones unilaterales.
- **Módulos afectados:** `docs/`, `backend/`, `mobile/`
- **Dependencias:** T-01.
- **Riesgo:** Medio (gestión de submódulos o sincronización).
- **Criterios de Aceptación:** Documento de gobernanza con especificación de versionado semántico, RFCs obligatorios para cambios de API y mecanismo de consumo idéntico.
- **Pruebas Necesarias:** Validación de esquema OpenAPI 3.0.1.
- **Estado:** PENDIENTE.

---

## 2. FASE 3 — Separación de Repositorios Git

### [T-03] Extracción y Congelación Canónica de `openapi.yaml`
- **Prioridad:** P0
- **Descripción:** Generar el archivo estático canónico `openapi.yaml` a partir del endpoint dinámico `/v3/api-docs.yaml` del backend utilizando una prueba automatizada en Spring Boot sin levantar servicios externos.
- **Objetivo:** Disponer del archivo físico oficial antes de iniciar la partición de repositorios.
- **Módulos afectados:** `backend/src/test/`
- **Dependencias:** T-02.
- **Riesgo:** Bajo.
- **Criterios de Aceptación:** Archivo `openapi.yaml` válido sintácticamente y que contenga los 31 endpoints de la API.
- **Pruebas Necesarias:** Validación con parser OpenAPI.
- **Estado:** PENDIENTE.

### [T-04] Creación del Repositorio Git Independiente `backend`
- **Prioridad:** P0
- **Descripción:** Inicializar el repositorio Git independiente en `backend/` preservando el historial de commits original de `develop`, configurando un `.gitignore` exclusivo para Java/Maven/IntelliJ, incorporando el `README.md` operativo y el contrato `openapi.yaml`.
- **Objetivo:** Independizar el ciclo de vida del backend manteniendo la trazabilidad histórica.
- **Módulos afectados:** `backend/`, `backend/.git`
- **Dependencias:** T-03.
- **Riesgo:** Medio (riesgo de alteración de árbol Git). Mitigación: Copia de seguridad intacta en `BankOs`.
- **Criterios de Aceptación:** `backend/.git` funcional, historial preservado, sin archivos de mobile, compilación `mvn test-compile` exitosa de forma aislada.
- **Pruebas Necesarias:** `git log`, `git status`, `mvn test`.
- **Estado:** PENDIENTE.

### [T-05] Creación del Repositorio Git Independiente `mobile`
- **Prioridad:** P0
- **Descripción:** Inicializar el repositorio Git independiente en `mobile/` preservando el historial de commits original de `develop`, configurando un `.gitignore` exclusivo para Flutter/Dart/Android/iOS, incorporando el `README.md` y vinculando el contrato `openapi.yaml`.
- **Objetivo:** Independizar el ciclo de vida del frontend móvil.
- **Módulos afectados:** `mobile/`, `mobile/.git`
- **Dependencias:** T-03.
- **Riesgo:** Medio. Mitigación: Copia de seguridad intacta en `BankOs`.
- **Criterios de Aceptación:** `mobile/.git` funcional, historial preservado, sin archivos de backend, comandos de Flutter ejecutables de forma aislada.
- **Pruebas Necesarias:** `git log`, `git status`.
- **Estado:** PENDIENTE.

### [T-06] Creación del Repositorio Central de Contratos (`contracts`)
- **Prioridad:** P0
- **Descripción:** Inicializar el repositorio `contracts/` con `openapi.yaml` como única fuente de verdad y documentar la integración (Git Submodule o script de verificación de paridad de contrato).
- **Objetivo:** Cumplir el mandato de que no existan contratos duplicados divergentes.
- **Módulos afectados:** `contracts/`, `backend/`, `mobile/`
- **Dependencias:** T-04, T-05.
- **Riesgo:** Bajo.
- **Criterios de Aceptación:** `openapi.yaml` centralizado, accesible por ambos repositorios con validación de suma de verificación SHA-256 idéntica.
- **Pruebas Necesarias:** Script de verificación de paridad (`check-contract.sh`).
- **Estado:** PENDIENTE.

### [T-07] Documentación de la Arquitectura de Repositorios
- **Prioridad:** P0
- **Descripción:** Redactar `docs/ARQUITECTURA_REPOSITORIOS.md` detallando la estructura de carpetas, instrucciones para clonar ambos repositorios, flujo de trabajo independiente y flujo de trabajo integrado.
- **Objetivo:** Proveer la documentación técnica requerida por el profesor para la entrega.
- **Módulos afectados:** `docs/ARQUITECTURA_REPOSITORIOS.md`
- **Dependencias:** T-04, T-05, T-06.
- **Riesgo:** Bajo.
- **Criterios de Aceptación:** Guía completa con comandos explícitos para desarrolladores de frontend y backend.
- **Pruebas Necesarias:** Revisión de legibilidad y enlaces relativos.
- **Estado:** PENDIENTE.

---

## 3. FASE 4 — Verificación y Formalización de Eliminación de Mocks

### [T-08] Informe Formal de Erradicación de Mocks
- **Prioridad:** P0
- **Descripción:** Registrar exhaustivamente en `docs/auditoria/INFORME_ELIMINACION_MOCKS.md` el inventario de mocks originales (`MockData.dart`), su eliminación en el commit `a5b5f5b`, la verificación de cero datos falsos en runtime en backend y frontend, y el deslinde con los mocks de pruebas (`MockClient`/Mockito).
- **Objetivo:** Cumplir formalmente con el entregable obligatorio de la Fase 4.
- **Módulos afectados:** `docs/auditoria/INFORME_ELIMINACION_MOCKS.md`
- **Dependencias:** T-07.
- **Riesgo:** Bajo.
- **Criterios de Aceptación:** Documento detallado con evidencia de búsqueda en todo el árbol de código.
- **Pruebas Necesarias:** Búsqueda recursiva de patrones mock en runtime.
- **Estado:** PENDIENTE.

---

## 4. FASE 5 — Corrección de Compilación Móvil e Integración E2E Real

### [T-09] Corrección de Métodos Faltantes en `ApiClient` de Flutter
- **Prioridad:** P0
- **Descripción:** Implementar los métodos auxiliares `delete()` y `patch()` en `mobile/lib/core/network/api_client.dart` delegando a `request(path, method: 'DELETE'/'PATCH')`.
- **Objetivo:** Resolver el error de compilación en `AuthRepository.dart`.
- **Módulos afectados:** `mobile/lib/core/network/api_client.dart`
- **Dependencias:** T-08.
- **Riesgo:** Bajo.
- **Criterios de Aceptación:** `ApiClient` compila y expone métodos `delete` y `patch`.
- **Pruebas Necesarias:** `flutter analyze mobile/lib/core/network/api_client.dart`.
- **Estado:** PENDIENTE.

### [T-10] Corrección de Constante de Color `error` en `AppColors`
- **Prioridad:** P0
- **Descripción:** Añadir `static const Color error = Color(0xFFB3261E);` en `mobile/lib/shared/constants/app_colors.dart` (o alias a `danger`).
- **Objetivo:** Resolver el error de compilación que afecta a `LoginScreen`, `MasterDashboardScreen`, `ProfileScreen` y widgets compartidos.
- **Módulos afectados:** `mobile/lib/shared/constants/app_colors.dart`
- **Dependencias:** T-08.
- **Riesgo:** Bajo.
- **Criterios de Aceptación:** Todas las referencias a `AppColors.error` compilan sin errores.
- **Pruebas Necesarias:** `flutter analyze mobile/lib/features/`.
- **Estado:** PENDIENTE.

### [T-11] Corrección de Importación en `master_auth_and_switcher_test.dart`
- **Prioridad:** P0
- **Descripción:** Agregar `import 'package:flutter/material.dart';` en `mobile/test/features/master_auth_and_switcher_test.dart`.
- **Objetivo:** Resolver el error sintáctico `Couldn't find constructor 'Color'`.
- **Módulos afectados:** `mobile/test/features/master_auth_and_switcher_test.dart`
- **Dependencias:** T-08.
- **Riesgo:** Bajo.
- **Criterios de Aceptación:** El archivo de test compila correctamente.
- **Pruebas Necesarias:** `flutter test mobile/test/features/master_auth_and_switcher_test.dart`.
- **Estado:** PENDIENTE.

### [T-12] Verificación Global de Calidad en Flutter
- **Prioridad:** P0
- **Descripción:** Ejecutar `flutter analyze` y la suite completa de pruebas unitarias y de widgets (`flutter test`).
- **Objetivo:** Asegurar 0 errores de análisis estático y 100% de tests aprobados en el frontend móvil.
- **Módulos afectados:** `mobile/`
- **Dependencias:** T-09, T-10, T-11.
- **Riesgo:** Medio.
- **Criterios de Aceptación:** Salida de `flutter analyze` limpia y 9/9 suites de prueba en `mobile/test` exitosas.
- **Pruebas Necesarias:** `flutter analyze`, `flutter test`.
- **Estado:** PENDIENTE.

### [T-13] Verificación de Integración End-to-End en Vivo
- **Prioridad:** P1
- **Descripción:** Verificar la comunicación HTTP en caliente: Flutter ↔ Spring Boot ↔ PostgreSQL (puerto 55432). Validar flujo de Login con captura de `tenant_code`, consulta de cuentas y realización de transferencia idempotente.
- **Objetivo:** Validar que los datos viajan por la red y se persisten en base de datos sin simulaciones.
- **Módulos afectados:** `mobile/`, `backend/`
- **Dependencias:** T-12.
- **Riesgo:** Medio (gestión de red/puertos).
- **Criterios de Aceptación:** Peticiones HTTP reales reflejadas en los logs de Spring Boot y registros en PostgreSQL.
- **Pruebas Necesarias:** Prueba de flujo E2E completa.
- **Estado:** PENDIENTE.

---

## 5. FASE 6 — Seguridad y Preparación para Uso Real

### [T-14] Auditoría Integral de Seguridad
- **Prioridad:** P1
- **Descripción:** Realizar revisión de seguridad financiera: aislamiento estricto de tenants, almacenamiento seguro en Keystore/Keychain (`FlutterSecureStorage`), firma y validación de Nimbus JWT, idempotencia SHA-256 y prevención de deadlocks.
- **Objetivo:** Garantizar que la aplicación cumple con estándares de seguridad bancaria.
- **Módulos afectados:** `backend/`, `mobile/`, `docs/auditoria/AUDITORIA_SEGURIDAD.md`
- **Dependencias:** T-13.
- **Riesgo:** Bajo.
- **Criterios de Aceptación:** Generación del entregable `docs/auditoria/AUDITORIA_SEGURIDAD.md` con recomendaciones de endurecimiento.
- **Pruebas Necesarias:** Verificación de filtros de seguridad y tests de aislamiento multi-inquilino.
- **Estado:** PENDIENTE.

---

## 6. FASE 7 — Docker y Entorno de Desarrollo

### [T-15] Estandarización de Infraestructura Docker y Documentación
- **Prioridad:** P1
- **Descripción:** Documentar la orquestación en `docs/DOCKER.md`: uso de PostgreSQL 16 con puerto alternativo `55432` para evitar colisiones en host, Redis 7, backend Spring Boot y comandos de ciclo de vida (`docker compose up -d`, `down`).
- **Objetivo:** Proveer un entorno replicable en un solo comando para cualquier evaluador.
- **Módulos afectados:** `docker-compose.yml`, `docs/DOCKER.md`
- **Dependencias:** T-07.
- **Riesgo:** Bajo.
- **Criterios de Aceptación:** Archivo `docs/DOCKER.md` completo con guías de solución de problemas de puertos y variables de entorno.
- **Pruebas Necesarias:** Validación de sintaxis `docker compose config`.
- **Estado:** PENDIENTE.

---

## 7. FASE 8 — Validación Final y Cierre

### [T-16] Verificación Cruzada de Independencia de Repositorios
- **Prioridad:** P0
- **Descripción:** Validar que `mobile` compila y corre tests sin la carpeta `backend`, y que `backend` compila y corre tests sin la carpeta `mobile`.
- **Objetivo:** Asegurar que no existan acoplamientos residuales ni dependencias cruzadas en el sistema de archivos.
- **Módulos afectados:** Ambos repositorios.
- **Dependencias:** T-12, T-13.
- **Riesgo:** Bajo.
- **Criterios de Aceptación:** Éxito independiente de `mvn test` en backend y `flutter test` en mobile.
- **Pruebas Necesarias:** Tests independientes en cada repositorio.
- **Estado:** PENDIENTE.

### [T-17] Elaboración del Informe Final Consolidado
- **Prioridad:** P0
- **Descripción:** Redacción de `docs/INFORME_FINAL_BANKOS.md` con el estado inicial vs final, resumen de cambios, diagramas de arquitectura, métricas finales y recomendaciones futuras.
- **Objetivo:** Entregar el reporte formal de cierre del proyecto para el usuario y el profesor.
- **Módulos afectados:** `docs/INFORME_FINAL_BANKOS.md`
- **Dependencias:** Todas las tareas anteriores.
- **Riesgo:** Bajo.
- **Criterios de Aceptación:** Documento exhaustivo con los 12 puntos requeridos en las especificaciones.
- **Pruebas Necesarias:** Revisión editorial y técnica completa.
- **Estado:** PENDIENTE.
