part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String email;
  final String phone;
  final String password;

  const RegisterSubmitted({
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [email, phone, password];
}

class VerifyOtpSubmitted extends AuthEvent {
  final String code;

  const VerifyOtpSubmitted({required this.code});

  @override
  List<Object?> get props => [code];
}
