# Fixtures de integración (Fase 0)

Respuestas reales del backend `dev` capturadas el 2026-11-17 contra `http://localhost:8080/api/v1`.

- `access_token` fue reemplazado por `<REDACTED>`: **no hay secretos en estos archivos**.
- Los `correlation_id` son reales pero no sensibles; sirven para verificar en pruebas que el cliente los conserva.
- `accounts_all_response.json` refleja el seed `V100` antes de operaciones financieras.
- `transactions_empty_response.json` es correcto: el seed no incluye movimientos.
- `transfer_preview_response.json` corresponde a USD → EUR con comisión fija de `1.5000` del tenant `BANCO_HORIZONTE`.

Estos archivos se usarán en tests unitarios/de widget como contrato congelado del backend.
