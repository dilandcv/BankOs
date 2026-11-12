# Multitenancy — BankOS

## Estado
- **Implementado (auditado):** No existe multitenancy implementado. No hay modelo de tenants, ni filtrado por tenant, ni contexto de seguridad.
- **Objetivo:** Aislamiento lógico estricto entre instituciones financieras dentro de la misma plataforma.

## Principio fundamental
- **Nunca confiar en el `tenant_id` enviado por Flutter o cualquier cliente.**
- El `tenant_id` debe obtenerse **exclusivamente** del contexto autenticado (JWT validado y/o contexto de seguridad resuelto en backend).

## Estrategia objetivo
- Modelo de datos con `tenant_id` en entidades de negocio (`users`, `customers`, `accounts`, `transactions`, `audit_logs`, etc.).
- Resolución de tenant por solicitud en capa de seguridad/filtros.
- Propagación del tenant al contexto de ejecución (ej. `SecurityContext`, holder por request) y uso obligatorio en servicios/repositorios.
- Consultas y escrituras siempre acotadas al tenant autenticado.
- Respuestas `403/404` apropiadas ante intentos de acceso cruzado (política a definir, evitando filtración de información).

## Validaciones requeridas
- Autenticación válida y tenant activo.
- Usuario pertenece al tenant del token.
- Todo recurso accedido (cuenta, transacción, cliente, configuración) pertenece al tenant autenticado.
- Operaciones financieras solo entre recursos permitidos por reglas del tenant (según diseño).

## Consideraciones de implementación (propuestas)
- Filtros JPA/Hibernate, especificaciones con predicado de tenant, o capa de repositorio que exija tenant explícito.
- Pruebas automatizadas de aislamiento (tenant A no puede leer/modificar datos de tenant B).
- Índices compuestos por `(tenant_id, ...)` para rendimiento y consistencia de consultas.

## Riesgos a evitar
- Endpoints que acepten `tenant_id` como parámetro de confianza.
- Consultas sin filtro de tenant.
- Cachés compartidos sin partición por tenant.
- Logs o errores que expongan datos de otros tenants.

## Pendientes
- Definir comportamiento exacto ante acceso no autorizado (403 vs 404).
- Implementar mecanismo técnico de enforcement en backend.
- Validar aislamiento en pruebas de integración y aceptación. 
