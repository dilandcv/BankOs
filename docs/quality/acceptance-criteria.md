# Criterios de aceptación — BankOS

## Estado
- **Implementado (auditado):** Funcionalidades no implementadas; los criterios siguientes son **objetivo** y deben ejecutarse cuando existan las capacidades correspondientes.
- **Ejecución:** **No ejecutadas** durante esta auditoría.

## Pruebas de aceptación obligatorias

| Prueba | Resultado esperado |
|---|---|
| Login tenant A | Acceso únicamente a recursos/datos del tenant A. |
| Login tenant B | Acceso únicamente a recursos/datos del tenant B. |
| Consultar cuenta de otro tenant | Acceso denegado (403/404 según política definida), sin filtración de datos. |
| Retiro sin saldo | Operación rechazada sin modificar saldos ni generar efectos inconsistentes. |
| Transferencia exitosa | Débito y crédito atómicos; saldos consistentes; movimientos registrados. |
| Transferencia multimoneda | Conversión y comisión correctas según tasas/configuración; asientos coherentes. |
| Reintento con misma llave | Una sola operación financiera efectiva; respuesta consistente (idempotencia). |
| Peticiones simultáneas | Sin doble ejecución ni corrupción de saldos (control de concurrencia). |
| Cuenta inactiva | Operación rechazada de acuerdo con reglas de estado. |
| Auditoría | Registro persistido con información relevante (actor, tenant, acción, recurso, resultado, correlación). |
| Webhook | Evento enviado/registrado después de confirmar la operación en base de datos. |

## Criterios transversales

- Todas las respuestas incluyen `correlation_id` y siguen el formato estándar.
- Operaciones financieras incluyen y respetan `Idempotency-Key`.
- No se puede operar sobre recursos de otro tenant.
- Los saldos y movimientos son reconstruibles y consistentes.

## Evidencia requerida (cuando se ejecuten)
- Identificador de caso/prueba, entorno, datos de prueba, pasos, resultado observado, logs/capturas relevantes y `correlation_id` asociado.
- Registrar desviaciones y defectos con severidad e impacto.

## Pendientes
- Definir datos de prueba, precondiciones exactas y automatización de estos escenarios.
- Acordar códigos HTTP/códigos de negocio definitivos para cada rechazo. 
