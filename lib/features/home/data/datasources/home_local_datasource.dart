import '../../../../core/data/mock_data_source.dart';
import '../models/transaction_preview_model.dart';
import '../models/wallet_summary_model.dart';

abstract class HomeLocalDataSource {
  Future<WalletSummaryModel> fetchWalletSummary();
  Future<List<TransactionPreviewModel>> fetchRecentTransactions();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final MockDataSource mockDataSource;

  HomeLocalDataSourceImpl({MockDataSource? mockDataSource})
      : mockDataSource = mockDataSource ?? MockDataSource();

  @override
  Future<WalletSummaryModel> fetchWalletSummary() async {
    await mockDataSource.simulateDelay();
    return const WalletSummaryModel(
      balance: MockDataSource.walletBalance,
      currency: MockDataSource.walletCurrency,
    );
  }

  @override
  Future<List<TransactionPreviewModel>> fetchRecentTransactions() async {
    await mockDataSource.simulateDelay();
    return MockDataSource.recentTransactions
        .map(TransactionPreviewModel.fromJson)
        .toList();
  }
}
