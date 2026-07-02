import '../entities/contact.dart';
import '../entities/quote.dart';
import '../entities/remittance.dart';
import '../entities/remittance_destination.dart';
import '../entities/transaction_detail.dart';

abstract class TransactionRepository {
  Future<List<Contact>> getContacts(String query);
  Future<TransactionDetail> getTransactionDetail(String id);
  Future<Quote> createQuote({
    required double amount,
    String destinationCountry = 'PE',
  });
  Future<Remittance> createRemittance({
    required String quoteId,
    required RemittanceDestination destination,
  });
  Future<Remittance> getRemittance(String id);
  Future<void> confirmDeposit(String remittanceId);
}
