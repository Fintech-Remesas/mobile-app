import '../entities/history_page.dart';
import '../repositories/history_repository.dart';

class GetTransactionHistoryParams {
  final int page;
  final int size;

  const GetTransactionHistoryParams({this.page = 0, this.size = 20});
}

class GetTransactionHistory {
  final HistoryRepository repository;

  GetTransactionHistory(this.repository);

  Future<HistoryPage> call(GetTransactionHistoryParams params) {
    return repository.getTransactionHistoryPage(
      page: params.page,
      size: params.size,
    );
  }
}
