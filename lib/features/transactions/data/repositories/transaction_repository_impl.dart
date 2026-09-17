import '../../domain/entities/contact.dart';
import '../../domain/entities/transaction_detail.dart';
import '../../domain/entities/traceability_metrics.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Contact>> getContacts() {
    return localDataSource.fetchContacts();
  }

  @override
  Future<TransactionDetail> getTransactionDetail(String id) async {
    try {
      final remoteData = await remoteDataSource.fetchTransactionDetail(id);
      
      final amount = _parseDouble(remoteData['amount']);
      final status = remoteData['status'] as String? ?? 'Completed';
      final recipient = remoteData['description'] as String? ?? remoteData['type'] as String? ?? 'N/A';
      
      return TransactionDetail(
        id: id,
        amount: amount,
        status: status,
        recipient: recipient,
        transactionHash: '', // Not provided by endpoint
        network: '',
        blockNumber: 0,
        confirmationStatus: 'confirmed',
        blockTimestamp: DateTime.parse(remoteData['createdAt'] as String),
      );
    } catch (e) {
      // Fallback to local if needed, or just throw
      return localDataSource.fetchTransactionDetail(id);
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Future<void> deposit(double amount, String currency, String cardId, String description) {
    return remoteDataSource.deposit(amount, currency, cardId, description);
  }

  @override
  Future<void> withdraw(double amount, String currency, String bankAccountId, String description) {
    return remoteDataSource.withdraw(amount, currency, bankAccountId, description);
  }

  @override
  Future<TraceabilityMetrics> getTraceabilityMetrics(String remittanceId) async {
    return await remoteDataSource.getTraceabilityMetrics(remittanceId);
  }
}
