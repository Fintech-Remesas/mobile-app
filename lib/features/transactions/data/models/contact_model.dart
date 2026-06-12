import '../../domain/entities/contact.dart';

class ContactModel extends Contact {
  const ContactModel({
    required super.id,
    required super.name,
    required super.phone,
  });

  factory ContactModel.fromJson(Map<String, String> json) {
    return ContactModel(
      id: json['id']!,
      name: json['name']!,
      phone: json['phone']!,
    );
  }
}
