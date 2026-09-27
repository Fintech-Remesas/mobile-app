import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ClaimWelcomeBonus implements UseCase<void, NoParams> {
  final AuthRepository repository;

  ClaimWelcomeBonus(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.claimWelcomeBonus();
  }
}
