import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';

/// Response returned after a successful user registration.
class RegisterResponse {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String country;
  final String preferredLanguage;
  final String? phone;

  const RegisterResponse({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.preferredLanguage,
    this.phone,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      country: json['profile']?['country'] as String? ?? 'PE',
      preferredLanguage: json['profile']?['preferredLanguage'] as String? ?? 'es',
      phone: json['phone'] as String?,
    );
  }
}

/// Response returned after a successful login.
class LoginResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String? ?? json['accessToken'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? json['tokenType'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as int? ?? json['expiresIn'] as int? ?? 0,
    );
  }
}

abstract class AuthRemoteDataSource {
  /// Registers a new user in the backend.
  /// Throws [Exception] on failure.
  Future<RegisterResponse> register({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String country,
    required String preferredLanguage,
    String? phone,
    String? initialPassword,
  });

  /// Authenticates a user with the backend.
  /// Throws [Exception] on failure.
  Future<LoginResponse> login({
    required String usernameOrEmail,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<RegisterResponse> register({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String country,
    required String preferredLanguage,
    String? phone,
    String? initialPassword,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.registerEndpoint}');

    final body = <String, dynamic>{
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'country': country,
      'preferredLanguage': preferredLanguage,
    };
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (initialPassword != null && initialPassword.isNotEmpty) {
      body['initialPassword'] = initialPassword;
    }

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final dataJson = json['data'] as Map<String, dynamic>? ?? json;
      return RegisterResponse.fromJson(dataJson);
    } else {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final message = json is Map
          ? (json['message'] ?? json['error'] ?? 'Error al registrar usuario')
          : 'Error al registrar usuario';
      throw Exception(message.toString());
    }
  }

  @override
  Future<LoginResponse> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}');

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final dataJson = json['data'] as Map<String, dynamic>? ?? json;
      return LoginResponse.fromJson(dataJson);
    } else {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final message = json is Map
          ? (json['message'] ?? json['error'] ?? 'Credenciales incorrectas')
          : 'Credenciales incorrectas';
      throw Exception(message.toString());
    }
  }
}
