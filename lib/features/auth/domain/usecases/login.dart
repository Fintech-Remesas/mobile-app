import '../../domain/repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<void> call(LoginParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}
