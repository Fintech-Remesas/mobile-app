abstract class PaymentMethodsRepository {
  Future<void> addCard({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cardBrand,
    required String cardType,
    String? alias,
  });

  Future<void> addBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountType,
    required String currency,
    required String country,
    String? alias,
  });

  Future<List<dynamic>> getCards();
  Future<void> deleteCard(String id);
  
  Future<List<dynamic>> getBankAccounts();
  Future<void> deleteBankAccount(String id);
}
