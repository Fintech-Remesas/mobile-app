class UserSearchModel {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? phone;

  UserSearchModel({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    return UserSearchModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
