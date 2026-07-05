class UserSearchModel {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? country;

  UserSearchModel({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.country,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    String? country;
    final profile = json['profile'];
    if (profile is Map && profile['country'] != null) {
      country = profile['country'].toString();
    }

    return UserSearchModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
      country: country,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
