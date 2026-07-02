import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  final String id;
  final String? keycloakUserId;
  final String name;
  final String phone;

  const Contact({
    required this.id,
    this.keycloakUserId,
    required this.name,
    required this.phone,
  });

  String get destinationUserId =>
      (keycloakUserId != null && keycloakUserId!.isNotEmpty)
          ? keycloakUserId!
          : id;

  @override
  List<Object?> get props => [id, keycloakUserId, name, phone];
}
