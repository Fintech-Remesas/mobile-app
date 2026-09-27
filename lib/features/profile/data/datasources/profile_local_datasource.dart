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
  final http.Client client;

  ProfileLocalDataSourceImpl({MockDataSource? mockDataSource, http.Client? client})
      : mockDataSource = mockDataSource ?? MockDataSource(),
        client = client ?? http.Client();

  @override
  Future<UserProfileModel> fetchProfile() async {
    final token = SessionManager.instance.token;
    if (token == null) {
      throw Exception('No token found');
    }

    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.meEndpoint}');
    final response = await client.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      final String firstName = data['firstName'] ?? '';
      final String lastName = data['lastName'] ?? '';
      final String email = data['email'] ?? '';
      final bool allowTestRecharge = data['allowTestRecharge'] ?? false;
      
      return UserProfileModel(
        name: '$firstName $lastName'.trim(),
        email: email,
        allowTestRecharge: allowTestRecharge,
      );
    } else if (response.statusCode == 401) {
      SessionManager.instance.notifySessionExpired();
      throw Exception('Session expired');
    } else {
      throw Exception('Failed to load profile');
    }
  }

  @override
  Future<void> logout() async {
    SessionManager.instance.clear();
    await mockDataSource.simulateDelay();
  }
}
