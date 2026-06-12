import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({required super.name, required super.email});

  factory UserProfileModel.fromMock() {
    return const UserProfileModel(
      name: 'John Doe',
      email: 'john.doe@example.com',
    );
  }
}
