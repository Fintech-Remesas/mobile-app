import '../../domain/entities/bank_account.dart';
import '../../domain/repositories/bank_account_repository.dart';
import '../datasources/bank_account_remote_datasource.dart';

class BankAccountRepositoryImpl implements BankAccountRepository {
  final BankAccountRemoteDataSource remoteDataSource;

  BankAccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BankAccount> addBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountType,
    required String currency,
    required String country,
    String? alias,
  }) {
    return remoteDataSource.addBankAccount(
      bankName: bankName,
      accountNumber: accountNumber,
      accountType: accountType,
      currency: currency,
      country: country,
      alias: alias,
    );
  }

  @override
  Future<List<BankAccount>> getBankAccounts() {
    return remoteDataSource.getBankAccounts();
  }

  @override
  Future<void> deleteBankAccount(String bankAccountId) {
    return remoteDataSource.deleteBankAccount(bankAccountId);
  }
}
