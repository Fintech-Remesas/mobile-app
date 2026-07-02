import '../../../../core/data/remittance_remote_datasource.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/quote.dart';
import '../../domain/entities/remittance.dart';
import '../../domain/entities/remittance_destination.dart';
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

  @override
  Future<Quote> createQuote({
    required double amount,
    String destinationCountry = 'PE',
  }) {
    return remoteDataSource.createQuote(
      sourceAmount: amount,
      destinationCountry: destinationCountry,
    );
  }

  @override
  Future<Remittance> createRemittance({
    required String quoteId,
    required RemittanceDestination destination,
  }) {
    return remoteDataSource.createRemittance(
      quoteId: quoteId,
      destination: destination,
    );
  }

  @override
  Future<Remittance> getRemittance(String id) {
    return remoteDataSource.fetchRemittance(id);
  }

  @override
  Future<void> confirmDeposit(String remittanceId) {
    return remoteDataSource.confirmDeposit(remittanceId);
  }
}
