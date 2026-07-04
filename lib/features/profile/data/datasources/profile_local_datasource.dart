import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/data/session_manager.dart';
import '../../../../core/constants/app_constants.dart';
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
    final token = SessionManager.instance.token;
    if (token != null) {
      try {
        final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.meEndpoint}');
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body)['data'];
          final String firstName = data['firstName'] ?? '';
          final String lastName = data['lastName'] ?? '';
          final String email = data['email'] ?? '';
          
          return UserProfileModel(
            name: '$firstName $lastName'.trim(),
            email: email,
          );
        }
      } catch (e) {
        // Fallback en caso de error de red
      }
    }

    await mockDataSource.simulateDelay();
    return UserProfileModel(
      name: MockDataSource.profileName,
      email: MockDataSource.profileEmail,
    );
  }

  @override
  Future<void> logout() async {
    SessionManager.instance.clear();
    await mockDataSource.simulateDelay();
  }
}
