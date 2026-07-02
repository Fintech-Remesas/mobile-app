import '../entities/bank_account.dart';

abstract class BankAccountRepository {
  Future<BankAccount> addBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountType,
    required String currency,
    required String country,
    String? alias,
  });

  Future<List<BankAccount>> getBankAccounts();

  Future<void> deleteBankAccount(String bankAccountId);
}
