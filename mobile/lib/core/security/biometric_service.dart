import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Desbloqueo **local** del token ya guardado.
///
/// No autentica ante el backend, no reemplaza la contraseña y no renueva
/// tokens vencidos. En F3 se rotula en la UI como “Desbloquear con biometría”.
class BiometricService {
  BiometricService({LocalAuthentication? localAuthentication})
      : _auth = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> get isAvailable async {
    if (kIsWeb) return false;
    try {
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unlock({required String reason}) async {
    if (kIsWeb) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } catch (_) {
      return false;
    }
  }
}
