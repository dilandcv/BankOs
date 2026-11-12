# Proceso de Pull Requests — BankOS

## Plantilla obligatoria
- Archivo: `.github/pull_request_template.md` (incluido en el repositorio como parte de esta documentación).
- Todo PR debe completar: descripción del problema, solución implementada, módulos modificados, evidencia de pruebas, posibles efectos secundarios y checklist de revisión.

## Creación del PR
1. Trabajar en una rama independiente (`feature/*`, `fix/*`, `refactor/*`, `docs/*`, `test/*`).
2. Asegurar commits descriptivos (Conventional Commits) y pruebas locales ejecutadas.
3. Subir la rama al remoto y abrir PR **hacia `develop`** (salvo promoción `develop -> main`).
4. Asignar/solicitar revisión a al menos otro integrante.
5. Describir claramente alcance, riesgos y cómo probar.

## Reglas de aprobación (PR hacia `develop`)
Un PR solamente podrá integrarse cuando:
- Tenga al menos **una aprobación de otro integrante**.
- **No tenga conflictos** con la rama destino.
- Las **pruebas correspondientes hayan pasado** (locales y/o CI cuando exista).
- **No introduzca errores evidentes**.
- **Respete la arquitectura** definida (backend modular, frontend feature-first, GoRouter, Riverpod, etc.).
- **No incluya credenciales, secretos ni tokens**.
- **Todas las conversaciones de revisión estén resueltas**.

> **Prohibido aprobar el propio Pull Request.**

## Revisión
- Revisar corrección funcional, seguridad (tenant, permisos, idempotencia), impacto en datos financieros, calidad de código y documentación.
- Solicitar cambios cuando haya riesgos, falta de pruebas o incumplimiento de estándares.
- El autor debe responder/corregir y volver a solicitar revisión.

## Merge y limpieza
- Integrar a `develop` solo tras cumplir las reglas anteriores.
- Preferir estrategia de merge acordada por el equipo (merge commit/squash/rebase) — **pendiente de definir**.
- Eliminar la rama de trabajo tras la integración.

## PR de `develop` a `main`
- Se crea únicamente cuando exista una versión estable candidata.
- Debe seguir el checklist de integración (pruebas, compilaciones, Docker, validaciones funcionales críticas) descrito en `git-workflow.md`.
- Requiere revisión y aprobación de otro integrante; nunca integración directa.

## Estado
- Plantilla de PR creada en `.github/`.
- Protecciones de rama y checks automáticos en GitHub: **no verificados**. 
