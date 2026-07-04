abstract class AuthRepository {
  Future<void> login({required String usernameOrEmail, required String password});
  Future<String> register({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String country,
    required String preferredLanguage,
    String? phone,
    String? initialPassword,
  });
  Future<void> verifyOtp({required String code});
}
