import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/data/session_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/mock_data_source.dart';
import '../../domain/entities/kyc_status.dart';

abstract class KycLocalDataSource {
  Future<void> submitKyc();
  Future<KycStatus> checkKycStatus();
}

class KycLocalDataSourceImpl implements KycLocalDataSource {
  final MockDataSource mockDataSource;
  KycStatus _status = KycStatus.notStarted;

  KycLocalDataSourceImpl({MockDataSource? mockDataSource})
      : mockDataSource = mockDataSource ?? MockDataSource();

  @override
  Future<void> submitKyc() async {
    final token = SessionManager.instance.token;
    if (token != null) {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.simulateKycEndpoint}');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _status = KycStatus.approved;
        return;
      } else {
        throw Exception('Error al verificar identidad: ${response.statusCode}');
      }
    }
    
    // Simular si falla o no hay token
    await Future.delayed(const Duration(milliseconds: 2500));
    _status = KycStatus.approved;
  }

  @override
  Future<KycStatus> checkKycStatus() async {
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
          final status = data['verificationStatus'];
          if (status == 'VERIFIED' || status == 'APPROVED') {
            _status = KycStatus.approved;
          } else {
            _status = KycStatus.pending;
          }
          return _status;
        }
      } catch (e) {
        // Fallback a pendiente en caso de error
      }
    }
    
    // Si no hay token o falla, mantener simulación
    await mockDataSource.simulateDelay();
    return _status;
  }

  void simulateApproval() => _status = KycStatus.approved;
  void simulateRejection() => _status = KycStatus.rejected;
}
