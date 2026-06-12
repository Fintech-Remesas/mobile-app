import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;

  HistoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<HistoryItem>> getTransactionHistory() {
    return localDataSource.fetchHistory();
  }
}
