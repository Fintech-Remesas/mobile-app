import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_response_model.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/data/models/user_me_model.dart';
import '../../domain/entities/kyc_status.dart';

abstract class KycRemoteDataSource {
  Future<void> submitKyc();
  Future<KycStatus> checkKycStatus();
}

class KycRemoteDataSourceImpl implements KycRemoteDataSource {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  KycRemoteDataSourceImpl({
    required this.apiClient,
    required this.tokenStorage,
  });

  KycStatus _mapStatus(String verificationStatus, bool canOperate) {
    if (canOperate || verificationStatus == 'VERIFIED') {
      return KycStatus.approved;
    }
    if (verificationStatus == 'PENDING' || verificationStatus == 'IN_REVIEW') {
      return KycStatus.pending;
    }
    if (verificationStatus == 'REJECTED') {
      return KycStatus.rejected;
    }
    return KycStatus.notStarted;
  }

  Future<UserMeModel> _fetchUser() async {
    final response = await apiClient.get<Map<String, dynamic>>('/api/v1/users/me');
    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty response from users/me');
    }

    final parsed = ApiResponseModel.fromJson(body, UserMeModel.fromJson);
    if (!parsed.success || parsed.data == null) {
      throw ApiException(parsed.message ?? 'Failed to load KYC status');
    }

    await tokenStorage.saveCanOperate(parsed.data!.canOperate);
    return parsed.data!;
  }

  @override
  Future<void> submitKyc() async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/v1/users/me/simulate-kyc',
      data: <String, dynamic>{},
    );

    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty response from simulate-kyc');
    }

    final parsed = ApiResponseModel.fromJson(
      body,
      (json) => json,
    );
    if (!parsed.success) {
      throw ApiException(parsed.message ?? 'KYC simulation failed');
    }

    final data = body['data'] as Map<String, dynamic>?;
    if (data != null) {
      await tokenStorage.saveCanOperate(data['canOperate'] as bool? ?? true);
    }
  }

  @override
  Future<KycStatus> checkKycStatus() async {
    final user = await _fetchUser();
    return _mapStatus(user.verificationStatus, user.canOperate);
  }
}
