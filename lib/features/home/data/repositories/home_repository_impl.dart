import '../../domain/entities/transaction_preview.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({required this.localDataSource});

  @override
  Future<WalletSummary> getWalletSummary() {
    return localDataSource.fetchWalletSummary();
  }

  @override
  Future<List<TransactionPreview>> getRecentTransactions() {
    return localDataSource.fetchRecentTransactions();
  }
}
