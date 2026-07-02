import '../../../../core/data/remittance_remote_datasource.dart';
import '../../domain/entities/history_page.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final RemittanceRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<HistoryPage> getTransactionHistoryPage({
    int page = 0,
    int size = 20,
  }) {
    return remoteDataSource.fetchHistoryPage(page: page, size: size);
  }
}
