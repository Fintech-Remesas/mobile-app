import '../../domain/repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String phone;
  final String password;

  const RegisterParams({
    required this.email,
    required this.phone,
    required this.password,
  });
}

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<void> call(RegisterParams params) {
    return repository.register(
      email: params.email,
      phone: params.phone,
      password: params.password,
    );
  }
}
