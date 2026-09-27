import '../../../../core/usecases/usecase.dart';
import '../repositories/home_repository.dart';

class ClaimInitialBonus implements UseCase<void, NoParams> {
  final HomeRepository repository;

  ClaimInitialBonus(this.repository);

  @override
  Future<void> call(NoParams params) async {
    await repository.claimInitialBonus();
  }
}
