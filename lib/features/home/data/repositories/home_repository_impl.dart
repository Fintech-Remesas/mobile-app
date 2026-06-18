import '../../../../core/data/remittance_remote_datasource.dart';
import '../../domain/entities/transaction_preview.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final RemittanceRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WalletSummary> getWalletSummary() {
    return remoteDataSource.fetchWalletSummary();
  }

  @override
  Future<List<TransactionPreview>> getRecentTransactions() {
    return remoteDataSource.fetchRecentTransactions();
  }
}
