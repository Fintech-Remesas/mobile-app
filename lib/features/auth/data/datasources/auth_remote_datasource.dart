import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_response_model.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/login_response_model.dart';
import '../models/user_me_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserMeModel> register({
    required String email,
    required String phone,
    required String password,
  });
  Future<UserMeModel> login({
    required String email,
    required String password,
  });
  Future<UserMeModel> fetchCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthRemoteDataSourceImpl({
    required this.apiClient,
    required this.tokenStorage,
  });

  Map<String, dynamic> _buildRegisterBody({
    required String email,
    required String phone,
    required String password,
  }) {
    final username = email.split('@').first;
    return {
      'email': email,
      'username': username,
      'phone': phone,
      'firstName': username,
      'lastName': 'User',
      'country': 'PE',
      'preferredLanguage': 'es',
      'initialPassword': password,
    };
  }

  Future<UserMeModel> _persistSession(LoginResponseModel login) async {
    await tokenStorage.saveTokens(
      accessToken: login.accessToken,
      refreshToken: login.refreshToken,
    );
    return fetchCurrentUser();
  }

  Future<void> _persistUserContext(UserMeModel user) async {
    await tokenStorage.saveUserId(user.id);
    if (user.keycloakUserId != null && user.keycloakUserId!.isNotEmpty) {
      await tokenStorage.saveKeycloakUserId(user.keycloakUserId!);
    }
    await tokenStorage.saveCanOperate(user.canOperate);
  }

  @override
  Future<UserMeModel> register({
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/v1/users/register',
      data: _buildRegisterBody(
        email: email,
        phone: phone,
        password: password,
      ),
    );

    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty response from register');
    }

    final parsed = ApiResponseModel.fromJson(body, UserMeModel.fromJson);
    if (!parsed.success || parsed.data == null) {
      throw ApiException(parsed.message ?? 'Registration failed');
    }

    await _persistUserContext(parsed.data!);
    return parsed.data!;
  }

  @override
  Future<UserMeModel> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    await tokenStorage.clearTokens();

    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/v1/users/login',
      data: {
        'usernameOrEmail': trimmedEmail,
        'password': trimmedPassword,
      },
    );

    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty response from login');
    }

    final parsed = ApiResponseModel.fromJson(
      body,
      LoginResponseModel.fromJson,
    );
    if (!parsed.success || parsed.data == null) {
      throw ApiException(
        parsed.message ?? 'Credenciales incorrectas o usuario no encontrado',
        statusCode: 401,
        endpoint: '/api/v1/users/login',
      );
    }

    final user = await _persistSession(parsed.data!);
    await _persistUserContext(user);
    return user;
  }

  @override
  Future<UserMeModel> fetchCurrentUser() async {
    final response = await apiClient.get<Map<String, dynamic>>('/api/v1/users/me');
    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty response from users/me');
    }

    final parsed = ApiResponseModel.fromJson(body, UserMeModel.fromJson);
    if (!parsed.success || parsed.data == null) {
      throw ApiException(parsed.message ?? 'Failed to load user profile');
    }

    await _persistUserContext(parsed.data!);
    return parsed.data!;
  }
}
