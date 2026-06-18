class UserMeModel {
  final String id;
  final String? keycloakUserId;
  final String email;
  final String username;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String accountStatus;
  final String verificationStatus;
  final bool canOperate;

  const UserMeModel({
    required this.id,
    this.keycloakUserId,
    required this.email,
    required this.username,
    this.phone,
    this.firstName,
    this.lastName,
    required this.accountStatus,
    required this.verificationStatus,
    required this.canOperate,
  });

  String get fullName {
    final parts = [firstName, lastName].where((p) => p != null && p.isNotEmpty);
    return parts.isEmpty ? username : parts.join(' ');
  }

  factory UserMeModel.fromJson(Map<String, dynamic> json) {
    return UserMeModel(
      id: json['id'] as String,
      keycloakUserId: json['keycloakUserId'] as String?,
      email: json['email'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      accountStatus: json['accountStatus'] as String? ?? 'REGISTERED',
      verificationStatus: json['verificationStatus'] as String? ?? 'NOT_STARTED',
      canOperate: json['canOperate'] as bool? ?? false,
    );
  }
}
