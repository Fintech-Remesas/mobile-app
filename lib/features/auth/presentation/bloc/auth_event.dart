part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String usernameOrEmail;
  final String password;

  const LoginSubmitted({required this.usernameOrEmail, required this.password});

  @override
  List<Object?> get props => [usernameOrEmail, password];
}

class RegisterSubmitted extends AuthEvent {
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String country;
  final String preferredLanguage;
  final String? phone;
  final String? initialPassword;

  const RegisterSubmitted({
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.preferredLanguage,
    this.phone,
    this.initialPassword,
  });

  @override
  List<Object?> get props => [
        email,
        username,
        firstName,
        lastName,
        country,
        preferredLanguage,
        phone,
        initialPassword,
      ];
}

class VerifyOtpSubmitted extends AuthEvent {
  final String code;

  const VerifyOtpSubmitted({required this.code});

  @override
  List<Object?> get props => [code];
}
