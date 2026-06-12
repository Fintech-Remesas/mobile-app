import '../../domain/entities/contact.dart';
import '../../domain/entities/transaction_detail.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Contact>> getContacts() {
    return localDataSource.fetchContacts();
  }

  @override
  Future<TransactionDetail> getTransactionDetail(String id) {
    return localDataSource.fetchTransactionDetail(id);
  }
}
