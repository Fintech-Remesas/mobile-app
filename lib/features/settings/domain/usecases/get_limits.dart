import '../../../../core/usecases/usecase.dart';
import '../entities/transfer_limits.dart';
import '../repositories/settings_repository.dart';

class GetLimits implements UseCase<TransferLimits, NoParams> {
  final SettingsRepository repository;

  GetLimits(this.repository);

  @override
  Future<TransferLimits> call(NoParams params) => repository.getLimits();
}
