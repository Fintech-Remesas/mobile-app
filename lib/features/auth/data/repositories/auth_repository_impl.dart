import '../../../../core/data/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      usernameOrEmail: usernameOrEmail,
      password: password,
    );
    SessionManager.instance.setSession(response.accessToken);
  }

  @override
  Future<String> register({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String country,
    required String preferredLanguage,
    String? phone,
    String? initialPassword,
  }) async {
    final response = await remoteDataSource.register(
      email: email,
      username: username,
      firstName: firstName,
      lastName: lastName,
      country: country,
      preferredLanguage: preferredLanguage,
      phone: phone,
      initialPassword: initialPassword,
    );
    return response.id;
  }

  @override
  Future<void> verifyOtp({required String code}) async {
    // TODO: implement when OTP endpoint is available in backend
    await Future.delayed(const Duration(seconds: 1));
  }
}
