import '../../../../core/usecases/usecase.dart';
import '../entities/history_item.dart';
import '../repositories/history_repository.dart';

class GetTransactionHistory implements UseCase<List<HistoryItem>, NoParams> {
  final HistoryRepository repository;

  GetTransactionHistory(this.repository);

  @override
  Future<List<HistoryItem>> call(NoParams params) {
    return repository.getTransactionHistory();
  }
}
