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
      await login(
        LoginParams(
          usernameOrEmail: event.usernameOrEmail,
          password: event.password,
        ),
      );
      emit(const AuthLoginSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final userId = await registerUser(RegisterParams(
        email: event.email,
        username: event.username,
        firstName: event.firstName,
        lastName: event.lastName,
        country: event.country,
        preferredLanguage: event.preferredLanguage,
        phone: event.phone,
        initialPassword: event.initialPassword,
      ));

      // Auto login fue removido a petición del usuario.
      emit(AuthRegisterSuccess(createdUserId: userId));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
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
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
