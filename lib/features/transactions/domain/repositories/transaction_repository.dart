import '../entities/contact.dart';
import '../entities/transaction_detail.dart';

abstract class TransactionRepository {
  Future<List<Contact>> getContacts();
  Future<TransactionDetail> getTransactionDetail(String id);
}
