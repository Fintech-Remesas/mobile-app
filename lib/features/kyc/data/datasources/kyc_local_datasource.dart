import '../../../../core/data/mock_data_source.dart';
import '../../domain/entities/kyc_status.dart';

abstract class KycLocalDataSource {
  Future<void> submitKyc();
  Future<KycStatus> checkKycStatus();
}

class KycLocalDataSourceImpl implements KycLocalDataSource {
  final MockDataSource mockDataSource;
  KycStatus _status = KycStatus.notStarted;

  KycLocalDataSourceImpl({MockDataSource? mockDataSource})
      : mockDataSource = mockDataSource ?? MockDataSource();

  @override
  Future<void> submitKyc() async {
    await mockDataSource.simulateDelay();
    _status = KycStatus.pending;
  }

  @override
  Future<KycStatus> checkKycStatus() async {
    await mockDataSource.simulateDelay();
    return _status;
  }

  void simulateApproval() => _status = KycStatus.approved;
  void simulateRejection() => _status = KycStatus.rejected;
}
