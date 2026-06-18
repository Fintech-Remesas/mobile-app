abstract class AuthRepository {
  bool get needsKyc;

  Future<void> login({required String email, required String password});
  Future<void> register({
    required String email,
    required String phone,
    required String password,
  });
  Future<void> verifyOtp({required String code});
}
