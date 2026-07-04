import '../../domain/repositories/auth_repository.dart';

class LoginParams {
  final String usernameOrEmail;
  final String password;

  const LoginParams({required this.usernameOrEmail, required this.password});
}

class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<void> call(LoginParams params) {
    return repository.login(
      usernameOrEmail: params.usernameOrEmail,
      password: params.password,
    );
  }
}
