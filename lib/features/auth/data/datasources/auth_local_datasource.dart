import '../../../../core/data/mock_data_source.dart';

abstract class AuthLocalDataSource {
  Future<void> login({required String email, required String password});
  Future<void> register({
    required String email,
    required String phone,
    required String password,
  });
  Future<void> verifyOtp({required String code});
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final MockDataSource mockDataSource;

  AuthLocalDataSourceImpl({MockDataSource? mockDataSource})
      : mockDataSource = mockDataSource ?? MockDataSource();

  @override
  Future<void> login({required String email, required String password}) async {
    await mockDataSource.simulateDelay();
  }

  @override
  Future<void> register({
    required String email,
    required String phone,
    required String password,
  }) async {
    await mockDataSource.simulateDelay();
  }

  @override
  Future<void> verifyOtp({required String code}) async {
    await mockDataSource.simulateDelay();
  }
}
