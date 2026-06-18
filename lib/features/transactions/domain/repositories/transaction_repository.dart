import '../entities/contact.dart';
import '../entities/transaction_detail.dart';

abstract class TransactionRepository {
  Future<List<Contact>> getContacts(String query);
  Future<TransactionDetail> getTransactionDetail(String id);
  Future<String> sendRemittance({
    required Contact recipient,
    required double amount,
  });
}
