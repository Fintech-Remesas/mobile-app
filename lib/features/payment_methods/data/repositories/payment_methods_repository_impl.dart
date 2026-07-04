import '../../domain/repositories/payment_methods_repository.dart';
import '../datasources/payment_methods_remote_datasource.dart';

class PaymentMethodsRepositoryImpl implements PaymentMethodsRepository {
  final PaymentMethodsRemoteDataSource remoteDataSource;

  PaymentMethodsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addCard({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cardBrand,
    required String cardType,
    String? alias,
  }) async {
    await remoteDataSource.addCard(
      cardholderName: cardholderName,
      cardNumber: cardNumber,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cardBrand: cardBrand,
      cardType: cardType,
      alias: alias,
    );
  }

  @override
  Future<void> addBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountType,
    required String currency,
    required String country,
    String? alias,
  }) async {
    await remoteDataSource.addBankAccount(
      bankName: bankName,
      accountNumber: accountNumber,
      accountType: accountType,
      currency: currency,
      country: country,
      alias: alias,
    );
  }

  @override
  Future<List<dynamic>> getCards() {
    return remoteDataSource.getCards();
  }

  @override
  Future<void> deleteCard(String id) {
    return remoteDataSource.deleteCard(id);
  }

  @override
  Future<List<dynamic>> getBankAccounts() {
    return remoteDataSource.getBankAccounts();
  }

  @override
  Future<void> deleteBankAccount(String id) {
    return remoteDataSource.deleteBankAccount(id);
  }
}
