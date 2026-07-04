import '../entities/bank_account.dart';
import '../repositories/payment_methods_repository.dart';

class GetBankAccounts {
  final PaymentMethodsRepository repository;

  GetBankAccounts(this.repository);

  Future<List<BankAccount>> call() async {
    final list = await repository.getBankAccounts();
    return list.map((e) => BankAccount.fromJson(e as Map<String, dynamic>)).toList();
  }
}
