import 'dart:async';
import 'package:http/http.dart' as http;

class SessionInterceptorClient extends http.BaseClient {
  final http.Client _inner;
  final void Function() onSessionExpired;

  SessionInterceptorClient(this._inner, {required this.onSessionExpired});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (response.statusCode == 401) {
      onSessionExpired();
    }
    return response;
  }
}
