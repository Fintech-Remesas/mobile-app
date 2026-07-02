import '../../domain/entities/contact.dart';

class ContactModel extends Contact {
  const ContactModel({
    required super.id,
    super.keycloakUserId,
    required super.name,
    required super.phone,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final name = '$firstName $lastName'.trim();
    return ContactModel(
      id: json['id']?.toString() ?? '',
      keycloakUserId: json['keycloakUserId'] as String?,
      name: name.isEmpty ? (json['username'] as String? ?? 'User') : name,
      phone: json['phone'] as String? ?? '',
    );
  }
}
