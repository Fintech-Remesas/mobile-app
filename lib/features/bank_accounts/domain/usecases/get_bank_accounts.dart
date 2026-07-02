import '../entities/bank_account.dart';
import '../repositories/bank_account_repository.dart';

class GetBankAccounts {
  final BankAccountRepository repository;

  GetBankAccounts(this.repository);

  Future<List<BankAccount>> call() => repository.getBankAccounts();
}
