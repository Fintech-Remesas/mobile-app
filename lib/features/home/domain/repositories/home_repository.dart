import '../entities/ledger_movement.dart';
import '../entities/transaction_preview.dart';
import '../entities/wallet_summary.dart';

abstract class HomeRepository {
  Future<WalletSummary> getWalletSummary();
  Future<List<TransactionPreview>> getRecentTransactions();
  Future<List<LedgerMovement>> getLedgerMovements();
}
