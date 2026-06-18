import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_me_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  UserMeModel? _currentUser;

  AuthRepositoryImpl({required this.remoteDataSource});

  UserMeModel? get currentUser => _currentUser;

  @override
  bool get needsKyc => _currentUser != null && !_currentUser!.canOperate;

  @override
  Future<void> login({required String email, required String password}) async {
    _currentUser = await remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<void> register({
    required String email,
    required String phone,
    required String password,
  }) async {
    _currentUser = await remoteDataSource.register(
      email: email,
      phone: phone,
      password: password,
    );
  }

  @override
  Future<void> verifyOtp({required String code}) async {
    // Backend has no OTP endpoint yet — passthrough for UI compatibility.
  }
}
