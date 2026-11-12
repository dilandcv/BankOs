# Estrategia de pruebas — BankOS

## Estado
- **Implementado (auditado):** No se observaron suites de pruebas significativas implementadas para el dominio de BankOS. Frontend es plantilla mínima (estructura de test por defecto posible, no verificada en ejecución). Backend inexistente.
- **Ejecución:** **No se ejecutaron pruebas** durante esta auditoría documental (restricción: no ejecutar/cambiar entorno de forma no requerida; foco en documentación).
- **Objetivo:** Cobertura adecuada de lógica crítica, seguridad multitenant e integridad financiera.

## Backend (objetivo)

### Herramientas y tipos
- **JUnit 5** para pruebas unitarias e integración.
- **Spring Boot Test** / slices (`@WebMvcTest`, `@DataJpaTest`, etc.) según corresponda.
- Pruebas de repositorios con base de datos de prueba (Testcontainers o equivalente, propuesto).
- Pruebas de autenticación y autorización (Spring Security).
- Pruebas de aislamiento multitenant.
- Pruebas de concurrencia (operaciones simultáneas sobre cuentas/saldos).
- Pruebas de idempotencia (misma `Idempotency-Key` y cuerpo).

### Enfoque
- Unitarias para reglas de negocio/validaciones en servicios.
- Integración para flujos completos (controller → service → repository → BD).
- Verificar atomicidad y rollback en fallos financieros.
- Validar que no haya efectos secundarios en operaciones rechazadas (ej. saldo insuficiente).

## Frontend (objetivo)

### Herramientas y tipos
- **Flutter Test** (unit/widget).
- Pruebas de widgets para componentes y pantallas clave.
- Pruebas de navegación **GoRouter** (guards, redirects, parámetros, sesión expirada).
- Pruebas de providers/notifiers **Riverpod** (estados loading/error/data, sesión).
- Pruebas de integración con API (mock de Dio o entorno de prueba), incluyendo manejo de errores y headers.

### Enfoque
- Validar flujos de autenticación y protección de rutas.
- Verificar que reintentos financieros preserven `Idempotency-Key` y payload (cuando se implemente).
- Confirmar que no se almacenen secretos en almacenamiento inseguro.

## Infraestructura y entorno de pruebas (pendiente)
- Definir perfiles de prueba, datos semilla y estrategia de aislamiento de BD.
- Integrar ejecución en CI cuando esté disponible.

## Riesgos actuales
- Sin automatización de pruebas del dominio, los regresos en seguridad financiera y multitenancy son altamente probables durante la hackatón. Priorizar pruebas de aceptación críticas tan pronto haya implementación. 
