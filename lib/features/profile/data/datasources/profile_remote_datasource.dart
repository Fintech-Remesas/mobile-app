import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_response_model.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/data/models/user_me_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> fetchProfile();
  Future<void> logout();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  ProfileRemoteDataSourceImpl({
    required this.apiClient,
    required this.tokenStorage,
  });

  @override
  Future<UserProfileModel> fetchProfile() async {
    final response = await apiClient.get<Map<String, dynamic>>('/api/v1/users/me');
    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty response from users/me');
    }

    final parsed = ApiResponseModel.fromJson(body, UserMeModel.fromJson);
    if (!parsed.success || parsed.data == null) {
      throw ApiException(parsed.message ?? 'Failed to load profile');
    }

    final user = parsed.data!;
    await tokenStorage.saveUserId(user.id);
    await tokenStorage.saveCanOperate(user.canOperate);

    return UserProfileModel(
      name: user.fullName,
      email: user.email,
    );
  }

  @override
  Future<void> logout() => tokenStorage.clear();
}
