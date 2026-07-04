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
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    if (date is List && date.length >= 6) {
      return DateTime(date[0], date[1], date[2], date[3], date[4], date[5]);
    }
    return DateTime.now();
  }
}
