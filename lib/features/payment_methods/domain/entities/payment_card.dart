class PaymentCard {
  final String id;
  final String cardholderName;
  final String last4;
  final String cardBrand;
  final String cardType;
  final int expiryMonth;
  final int expiryYear;
  final String alias;
  final bool isPrimary;
  final DateTime createdAt;

  PaymentCard({
    required this.id,
    required this.cardholderName,
    required this.last4,
    required this.cardBrand,
    required this.cardType,
    required this.expiryMonth,
    required this.expiryYear,
    required this.alias,
    required this.isPrimary,
    required this.createdAt,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'] ?? '',
      cardholderName: json['cardholderName'] ?? '',
      last4: json['last4'] ?? '',
      cardBrand: json['cardBrand'] ?? '',
      cardType: json['cardType'] ?? '',
      expiryMonth: json['expiryMonth'] ?? 0,
      expiryYear: json['expiryYear'] ?? 0,
      alias: json['alias'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
