# Definition of Done (DoD) — BankOS

Una tarea **solamente estará terminada** cuando se cumplan todos los criterios aplicables:

## Implementación y calidad
- [ ] El código está implementado y alineado con la arquitectura definida.
- [ ] Las pruebas correspondientes han sido ejecutadas (unitarias/integración/manuales según aplique) y sus resultados están documentados en el PR.
- [ ] No existen errores de compilación en los componentes afectados.
- [ ] No hay secretos, credenciales ni tokens expuestos en el código o configuración versionada.
- [ ] Se respetan las convenciones de codificación (Java/Flutter/PostgreSQL) y el flujo Git.

## Seguridad y dominio (cuando aplique)
- [ ] Se valida el `tenant` desde el contexto autenticado (nunca desde el cliente).
- [ ] Se respetan permisos/roles en backend.
- [ ] Las operaciones financieras son atómicas, idempotentes (si aplica) y no violan reglas de negocio.
- [ ] No se exponen entidades JPA ni detalles sensibles.

## Documentación y revisión
- [ ] La documentación relevante en `docs/` y/o contratos de API está actualizada cuando corresponde.
- [ ] El Pull Request está creado con la plantilla completa y evidencia de pruebas.
- [ ] Otro integrante ha revisado el Pull Request.
- [ ] El Pull Request está aprobado.
- [ ] Los cambios están integrados en `develop`.

## Notas
- Si alguna verificación no aplica o no pudo ejecutarse, debe indicarse explícitamente en el PR con la justificación y el riesgo asociado.
- El cumplimiento del DoD no sustituye las pruebas de aceptación ni la validación de integración previa a `main`. 
