import '../../../../core/data/remittance_remote_datasource.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final RemittanceRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HistoryItem>> getTransactionHistory() {
    return remoteDataSource.fetchHistory();
  }
}
