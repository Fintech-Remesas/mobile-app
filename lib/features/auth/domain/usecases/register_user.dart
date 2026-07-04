import '../../domain/repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String country;
  final String preferredLanguage;
  final String? phone;
  final String? initialPassword;

  const RegisterParams({
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.preferredLanguage,
    this.phone,
    this.initialPassword,
  });
}

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  /// Returns the created user's ID.
  Future<String> call(RegisterParams params) {
    return repository.register(
      email: params.email,
      username: params.username,
      firstName: params.firstName,
      lastName: params.lastName,
      country: params.country,
      preferredLanguage: params.preferredLanguage,
      phone: params.phone,
      initialPassword: params.initialPassword,
    );
  }
}
