import '../../../../core/data/mock_data_source.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel> fetchProfile();
  Future<void> logout();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final MockDataSource mockDataSource;

  ProfileLocalDataSourceImpl({MockDataSource? mockDataSource})
      : mockDataSource = mockDataSource ?? MockDataSource();

  @override
  Future<UserProfileModel> fetchProfile() async {
    await mockDataSource.simulateDelay();
    return UserProfileModel(
      name: MockDataSource.profileName,
      email: MockDataSource.profileEmail,
    );
  }

  @override
  Future<void> logout() async {
    await mockDataSource.simulateDelay();
  }
}
