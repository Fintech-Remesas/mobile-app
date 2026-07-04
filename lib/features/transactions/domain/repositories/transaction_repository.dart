import '../entities/contact.dart';
import '../entities/transaction_detail.dart';

abstract class TransactionRepository {
  Future<List<Contact>> getContacts();
  Future<TransactionDetail> getTransactionDetail(String id);
  Future<void> deposit(double amount, String currency, String cardId, String description);
  Future<void> withdraw(double amount, String currency, String bankAccountId, String description);
}
