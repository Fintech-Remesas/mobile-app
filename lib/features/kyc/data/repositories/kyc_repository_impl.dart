import '../../domain/entities/kyc_status.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../datasources/kyc_local_datasource.dart';

class KycRepositoryImpl implements KycRepository {
  final KycLocalDataSourceImpl localDataSource;

  KycRepositoryImpl({required this.localDataSource});

  @override
  Future<void> submitKyc() => localDataSource.submitKyc();

  @override
  Future<KycStatus> checkKycStatus() => localDataSource.checkKycStatus();

  void simulateApproval() => localDataSource.simulateApproval();

  void simulateRejection() => localDataSource.simulateRejection();
}
