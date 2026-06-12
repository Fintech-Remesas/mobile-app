import '../../domain/repositories/auth_repository.dart';

class VerifyOtpParams {
  final String code;

  const VerifyOtpParams({required this.code});
}

class VerifyOtp {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  Future<void> call(VerifyOtpParams params) {
    return repository.verifyOtp(code: params.code);
  }
}
