import '../../../../core/data/remittance_remote_datasource.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/transaction_detail.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final RemittanceRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Contact>> getContacts(String query) {
    return remoteDataSource.searchContacts(query);
  }

  @override
  Future<TransactionDetail> getTransactionDetail(String id) {
    return remoteDataSource.fetchTransactionDetail(id);
  }
}
