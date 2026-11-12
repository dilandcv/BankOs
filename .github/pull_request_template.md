# Título descriptivo

<!-- Ejemplo: feat: implementar autenticación JWT para tenant -->

## Descripción del problema
<!-- ¿Qué problema resuelve este cambio? Enlaza issue/tarea si aplica. -->

## Solución implementada
<!-- Resumen claro de los cambios realizados. -->

## Módulos modificados
<!-- Marca los que apliquen -->
- [ ] Backend — `tenants`
- [ ] Backend — `authentication`
- [ ] Backend — `users`
- [ ] Backend — `customers`
- [ ] Backend — `accounts`
- [ ] Backend — `transactions`
- [ ] Backend — `idempotency`
- [ ] Backend — `settings`
- [ ] Backend — `audit`
- [ ] Backend — `webhooks`
- [ ] Frontend — `authentication`
- [ ] Frontend — `dashboard`
- [ ] Frontend — `accounts`
- [ ] Frontend — `transactions`
- [ ] Frontend — `history`
- [ ] Frontend — `profile`
- [ ] Infraestructura / Docker / BD
- [ ] Documentación

## Evidencia de pruebas
<!-- Comandos ejecutados, resultados, capturas o logs relevantes. Indica si no se ejecutaron pruebas y por qué. -->
- [ ] Pruebas unitarias
- [ ] Pruebas de integración
- [ ] Pruebas manuales
- Detalle:

## Posibles efectos secundarios
<!-- Impacto en otros módulos, migraciones, contratos de API, compatibilidad, etc. -->

## Checklist de revisión
- [ ] El cambio respeta la arquitectura definida (monolito modular backend / feature-first frontend).
- [ ] No se exponen entidades JPA directamente en la API.
- [ ] No hay lógica financiera en controllers ni en Flutter.
- [ ] Se usan `BigDecimal` (Java) / `NUMERIC` (PostgreSQL) para importes cuando aplica.
- [ ] Operaciones financieras son transaccionales e idempotentes cuando aplica.
- [ ] Se valida el `tenant` desde el contexto autenticado (nunca confiar en el cliente).
- [ ] No se incluyen credenciales, secretos ni tokens en el repositorio.
- [ ] La documentación relevante fue actualizada.
- [ ] No hay errores de compilación evidentes.
- [ ] Las conversaciones de revisión están resueltas.

> **Nota:** Este PR debe ser revisado y aprobado por al menos otro integrante. Está prohibido aprobar el propio Pull Request.
