import '../repositories/bank_account_repository.dart';

class DeleteBankAccount {
  final BankAccountRepository repository;

  DeleteBankAccount(this.repository);

  Future<void> call(String bankAccountId) {
    return repository.deleteBankAccount(bankAccountId);
  }
}
