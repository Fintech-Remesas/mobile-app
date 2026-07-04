import '../repositories/payment_methods_repository.dart';

class AddCardParams {
  final String cardholderName;
  final String cardNumber;
  final int expiryMonth;
  final int expiryYear;
  final String cardBrand;
  final String cardType;
  final String? alias;

  AddCardParams({
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardBrand,
    required this.cardType,
    this.alias,
  });
}

class AddCard {
  final PaymentMethodsRepository repository;

  AddCard(this.repository);

  Future<void> call(AddCardParams params) {
    return repository.addCard(
      cardholderName: params.cardholderName,
      cardNumber: params.cardNumber,
      expiryMonth: params.expiryMonth,
      expiryYear: params.expiryYear,
      cardBrand: params.cardBrand,
      cardType: params.cardType,
      alias: params.alias,
    );
  }
}
