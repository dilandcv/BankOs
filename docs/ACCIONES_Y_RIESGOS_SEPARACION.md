# DOCUMENTO DE ACCIONES Y RIESGOS PARA LA SEPARACIÓN DE REPOSITORIOS (FASE 3)

**Proyecto:** BankOS  
**Fecha:** 2026-11-18  
**Autor:** Senior Software Architect  
**Carácter:** Pre-ejecución obligatoria  

---

## 1. Alcance y Restricciones Previas

En estricto cumplimiento de las condiciones establecidas por el usuario:
1. **El directorio raíz `BankOs` se conservará íntegro** como respaldo seguro del monorepo original.
2. **No se eliminarán ni sobrescribirán archivos originales** sin comprobación previa.
3. **No se configurarán remotos ni se realizarán operaciones `git push`** hasta que el usuario suministre las URLs oficiales y la autorización expresa.
4. **No se modificarán la lógica de negocio ni los archivos de la aplicación móvil en esta fase.** Esas modificaciones se reservan para la Fase 5.

---

## 2. Secuencia Detallada de Acciones a Ejecutar

### Paso 1: Extracción Segura del Contrato Canónico `openapi.yaml`
- Se creará una prueba unitaria / de contexto en Spring Boot (`OpenApiExportTest.java`) para exportar directamente el archivo YAML generado por `springdoc-openapi` a un archivo estático.
- Se calculará inmediatamente su suma criptográfica SHA-256 (`openapi.sha256`) para garantizar la inmutabilidad de la versión `v1.0.0`.

### Paso 2: Creación del Repositorio Central `contracts`
- Directorio: `contracts/` (preparado para ser publicado como repositorio independiente `BankOs-contracts`).
- Se inicializará su propio Git (`contracts/.git`).
- Contendrá: `openapi.yaml`, `openapi.sha256`, `README.md` y `GOVERNANCE.md`.
- Se configurará un script de verificación de paridad para asegurar que ningún repositorio satélite altere el contrato.

### Paso 3: Separación del Repositorio `backend`
- Directorio objetivo: `backend/`
- Se inicializará su propio repositorio Git (`backend/.git`).
- Se importará el historial relevante de los commits de `develop` (`006fa13`, `927a115`, `a5b5f5b`, `d49167f`, `f19949c`).
- Se configurará `.gitignore` específico de Java/Maven (excluyendo `target/`, `.m2/`, `.idea/`, `.env`).
- Se incorporará el `README.md` de backend con instrucciones de arranque independiente, migraciones Flyway y Docker.
- Se verificará que compile de manera aislada (`docker run ... mvn test-compile`).

### Paso 4: Separación del Repositorio `mobile`
- Directorio objetivo: `mobile/`
- Se inicializará su propio repositorio Git (`mobile/.git`).
- Se importará el historial relevante de los commits de `develop`.
- Se configurará `.gitignore` específico de Flutter/Dart/Android/iOS (excluyendo `.dart_tool/`, `build/`, `.env`, secretos).
- Se incorporará el `README.md` de mobile con instrucciones de configuración, emuladores y pruebas.
- Se verificará que los comandos de Flutter reconozcan el repositorio como un proyecto independiente.

### Paso 5: Protección de la Raíz `BankOs` y No-Anidamiento
- Para evitar que Git interprete las subcarpetas `.git` como submódulos sucios en el monorepo de respaldo, se configurarán las directivas de exclusión adecuadas en `.git/info/exclude` del repositorio raíz, manteniendo la copia de respaldo intacta.

### Paso 6: Verificación de Independencia Operativa
- Validación de que `backend` pueda compilar y ejecutar tests de Testcontainers sin la existencia de `mobile/`.
- Validación de que `mobile` mantenga su estructura de paquetes y configuración sin la existencia de `backend/`.

### Paso 7: Documentación de la Entrega
- Redacción completa de `docs/ARQUITECTURA_REPOSITORIOS.md`.

---

## 3. Matriz de Riesgos Identificados y Estrategias de Mitigación

| ID | Riesgo Identificado | Nivel de Riesgo | Impacto Potencial | Estrategia de Mitigación |
|:---:|---|:---:|---|---|
| **R-01** | **Pérdida o corrupción del historial Git existente** | Alto | Pérdida de la autoría y trazabilidad de los commits anteriores. | El repositorio raíz `BankOs` no se toca. Los nuevos repositorios preservan los commits mediante replicación de árbol de trabajo con autoría y marcas de tiempo idénticas. |
| **R-02** | **Divergencia entre contratos de API** | Alto | El frontend y el backend implementan versiones incompatibles de DTOs o endpoints. | Creación del repositorio central `contracts` como única fuente de verdad con test de paridad SHA-256 obligatorio en CI/CD. |
| **R-03** | **Fuga accidental de credenciales o secretos en Git** | Crítico | Exposición de secretos JWT, contraseñas de BD o claves privadas en repositorios públicos. | Aplicación de `.gitignore` estrictos. Exclusión expresa de `.env`, `keystore.jks` y secretos. Revisión previa de `git status` antes de confirmar cualquier commit. |
| **R-04** | **Repositorios anidados accidentalmente (*dirty submodules*)** | Medio | Git raíz bloquea o malinterpreta los nuevos `.git` internos. | Verificación explícita de `git status` en la raíz y en cada subcarpeta, asegurando independencia total de los árboles `.git`. |
| **R-05** | **Configuración errónea o involuntaria de remotos remotos** | Bajo | Envío de código a repositorios remotos incorrectos. | Regla estricta: No se ejecuta `git remote add` ni `git push` sin URLs suministradas por el usuario. |
| **R-06** | **Ruptura de compilación por rutas relativas en Docker** | Medio | Docker Compose no encuentra el contexto de construcción del backend tras la separación. | El archivo `docker-compose.yml` se configurará para operar tanto dentro de `backend/` como en la raíz de despliegue. |
