import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/verify_otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final RegisterUser registerUser;
  final VerifyOtp verifyOtp;

  AuthBloc({
    required this.login,
    required this.registerUser,
    required this.verifyOtp,
  }) : super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<VerifyOtpSubmitted>(_onVerifyOtpSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await login(LoginParams(email: event.email, password: event.password));
      emit(const AuthLoginSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await registerUser(RegisterParams(
        email: event.email,
        phone: event.phone,
        password: event.password,
      ));
      emit(const AuthRegisterSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onVerifyOtpSubmitted(
    VerifyOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await verifyOtp(VerifyOtpParams(code: event.code));
      emit(const AuthVerifyOtpSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
