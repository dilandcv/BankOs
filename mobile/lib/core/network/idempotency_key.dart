import 'dart:convert';

import 'package:uuid/uuid.dart';

/// Mantiene una misma llave mientras el cuerpo de la operación no cambie.
///
/// Si el usuario corrige el monto y vuelve a enviar, esa es una operación
/// nueva: se genera otra llave para no recibir un `IDEMPOTENCY_CONFLICT`.
class IdempotencyKeyKeeper {
  IdempotencyKeyKeeper({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  String _key = '';
  String? _lastFingerprint;

  String nextKey(Object? body) {
    final fingerprint = jsonEncode(body);
    if (_key.isEmpty || _lastFingerprint != fingerprint) {
      _key = _uuid.v4();
      _lastFingerprint = fingerprint;
    }
    return _key;
  }
}
