import '../../../../core/usecases/usecase.dart';
import '../entities/kyc_status.dart';
import '../repositories/kyc_repository.dart';

class CheckKycStatus implements UseCase<KycStatus, NoParams> {
  final KycRepository repository;

  CheckKycStatus(this.repository);

  @override
  Future<KycStatus> call(NoParams params) => repository.checkKycStatus();
}
