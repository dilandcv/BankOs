import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verificar paridad estricta de openapi.yaml contra openapi.sha256', () async {
    final contractFile = File('openapi.yaml');
    expect(await contractFile.exists(), isTrue,
        reason: 'El archivo openapi.yaml debe existir en la raíz de mobile/');

    final checksumFile = File('openapi.sha256');
    expect(await checksumFile.exists(), isTrue,
        reason: 'El archivo openapi.sha256 debe existir en la raíz de mobile/');

    final expectedHash = (await checksumFile.readAsString()).trim().split(RegExp(r'\s+')).first;
    final bytes = await contractFile.readAsBytes();
    final actualHash = sha256.convert(bytes).toString();

    expect(actualHash, equals(expectedHash),
        reason: 'El contrato openapi.yaml ha sido alterado y diverge del hash oficial');
  });
}
