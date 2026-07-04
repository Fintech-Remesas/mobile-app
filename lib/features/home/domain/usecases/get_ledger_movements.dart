import '../../../../core/usecases/usecase.dart';
import '../entities/ledger_movement.dart';
import '../repositories/home_repository.dart';

class GetLedgerMovements implements UseCase<List<LedgerMovement>, NoParams> {
  final HomeRepository repository;

  GetLedgerMovements(this.repository);

  @override
  Future<List<LedgerMovement>> call(NoParams params) {
    return repository.getLedgerMovements();
  }
}
