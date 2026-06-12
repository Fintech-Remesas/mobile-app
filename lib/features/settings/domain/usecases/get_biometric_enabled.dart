import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class GetBiometricEnabled implements UseCase<bool, NoParams> {
  final SettingsRepository repository;

  GetBiometricEnabled(this.repository);

  @override
  Future<bool> call(NoParams params) => repository.getBiometricEnabled();
}
