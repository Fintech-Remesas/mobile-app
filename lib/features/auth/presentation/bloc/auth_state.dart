part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthLoginSuccess extends AuthState {
  final bool needsKyc;

  const AuthLoginSuccess({required this.needsKyc});

  @override
  List<Object?> get props => [needsKyc];
}

class AuthRegisterSuccess extends AuthState {
  const AuthRegisterSuccess();
}

class AuthVerifyOtpSuccess extends AuthState {
  const AuthVerifyOtpSuccess();
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
