import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<void> login({required String email, required String password}) {
    return localDataSource.login(email: email, password: password);
  }

  @override
  Future<void> register({
    required String email,
    required String phone,
    required String password,
  }) {
    return localDataSource.register(
      email: email,
      phone: phone,
      password: password,
    );
  }

  @override
  Future<void> verifyOtp({required String code}) {
    return localDataSource.verifyOtp(code: code);
  }
}
