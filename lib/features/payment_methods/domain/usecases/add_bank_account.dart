import '../repositories/payment_methods_repository.dart';

class AddBankAccountParams {
  final String bankName;
  final String accountNumber;
  final String accountType;
  final String currency;
  final String country;
  final String? alias;

  AddBankAccountParams({
    required this.bankName,
    required this.accountNumber,
    required this.accountType,
    required this.currency,
    required this.country,
    this.alias,
  });
}

class AddBankAccount {
  final PaymentMethodsRepository repository;

  AddBankAccount(this.repository);

  Future<void> call(AddBankAccountParams params) {
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
