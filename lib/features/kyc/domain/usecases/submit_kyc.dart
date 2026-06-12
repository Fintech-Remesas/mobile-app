import '../../../../core/usecases/usecase.dart';
import '../repositories/kyc_repository.dart';

class SubmitKyc implements UseCase<void, NoParams> {
  final KycRepository repository;

  SubmitKyc(this.repository);

  @override
  Future<void> call(NoParams params) => repository.submitKyc();
}
