import 'dart:convert';

class JwtDecoder {
  static Map<String, dynamic> decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    var resp = utf8.decode(base64Url.decode(normalized));
    return json.decode(resp);
  }
}

class SessionManager {
  static final SessionManager instance = SessionManager._internal();
  SessionManager._internal();

  String? userId;
  String? token;

  void setSession(String accessToken) {
    token = accessToken;
    try {
      final payload = JwtDecoder.decode(accessToken);
      userId = payload['sub'];
    } catch (e) {
      print('Error decoding token: $e');
    }
  }

  void clear() {
    userId = null;
    token = null;
  }
}
