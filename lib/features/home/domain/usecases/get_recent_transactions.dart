import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_preview.dart';
import '../repositories/home_repository.dart';

class GetRecentTransactions implements UseCase<List<TransactionPreview>, NoParams> {
  final HomeRepository repository;

  GetRecentTransactions(this.repository);

  @override
  Future<List<TransactionPreview>> call(NoParams params) {
    return repository.getRecentTransactions();
  }
}
