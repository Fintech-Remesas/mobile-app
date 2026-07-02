import '../entities/bank_account.dart';
import '../repositories/bank_account_repository.dart';

class AddBankAccountParams {
  final String bankName;
  final String accountNumber;
  final String accountType;
  final String currency;
  final String country;
  final String? alias;

  const AddBankAccountParams({
    required this.bankName,
    required this.accountNumber,
    required this.accountType,
    required this.currency,
    required this.country,
    this.alias,
  });
}

class AddBankAccount {
  final BankAccountRepository repository;

  AddBankAccount(this.repository);

  Future<BankAccount> call(AddBankAccountParams params) {
    return repository.addBankAccount(
      bankName: params.bankName,
      accountNumber: params.accountNumber,
      accountType: params.accountType,
      currency: params.currency,
      country: params.country,
      alias: params.alias,
    );
  }
}
