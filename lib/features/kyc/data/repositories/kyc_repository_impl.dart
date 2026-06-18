import '../../domain/entities/kyc_status.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../datasources/kyc_remote_datasource.dart';

class KycRepositoryImpl implements KycRepository {
  final KycRemoteDataSource remoteDataSource;

  KycRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> submitKyc() => remoteDataSource.submitKyc();

  @override
  Future<KycStatus> checkKycStatus() => remoteDataSource.checkKycStatus();
}
