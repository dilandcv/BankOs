import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mobile/core/storage/secure_session_store.dart';

class MemorySessionStorage implements SessionStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<void> delete({required String key}) async => values.remove(key);

  @override
  Future<Map<String, String>> readAll() async => Map.unmodifiable(values);

  @override
  Future<void> deleteAll() async => values.clear();
}

class FakeResponse {
  const FakeResponse(this.statusCode, this.body);

  final int statusCode;
  final Map<String, dynamic> body;
}

class RecordedRequest {
  RecordedRequest(this.options, this.decodedBody);

  final RequestOptions options;
  final Map<String, dynamic>? decodedBody;
}

/// Adaptador que responde según la ruta y registra todo lo enviado.
class RoutingFakeAdapter implements HttpClientAdapter {
  final Map<String, FakeResponse> routes = <String, FakeResponse>{};
  final List<RecordedRequest> requests = <RecordedRequest>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    Uint8List? bytes;
    if (requestStream != null) {
      bytes = await requestStream.fold<Uint8List>(
        Uint8List(0),
        (previous, element) => Uint8List.fromList(<int>[...previous, ...element]),
      );
    }

    Map<String, dynamic>? decoded;
    if (bytes != null && bytes.isNotEmpty) {
      decoded = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    }
    requests.add(RecordedRequest(options, decoded));

    final response = routes[options.path] ??
        const FakeResponse(
          404,
          <String, dynamic>{
            'success': false,
            'code': 'NOT_FOUND',
            'message': 'Ruta no configurada en el test',
            'data': null,
            'correlation_id': 'test',
          },
        );

    return ResponseBody.fromString(
      jsonEncode(response.body),
      response.statusCode,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
