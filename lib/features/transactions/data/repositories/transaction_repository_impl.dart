import '../../domain/entities/contact.dart';
import '../../domain/entities/transaction_detail.dart';
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
  Future<TransactionDetail> getTransactionDetail(String id) {
    return localDataSource.fetchTransactionDetail(id);
  }

  @override
  Future<void> deposit(double amount, String currency, String cardId, String description) {
    return remoteDataSource.deposit(amount, currency, cardId, description);
  }

  @override
  Future<void> withdraw(double amount, String currency, String bankAccountId, String description) {
    return remoteDataSource.withdraw(amount, currency, bankAccountId, description);
  }
}
