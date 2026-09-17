import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/session_manager.dart';
import '../models/traceability_metrics_model.dart';

abstract class TransactionRemoteDataSource {
  Future<void> deposit(double amount, String currency, String cardId, String description);
  Future<void> withdraw(double amount, String currency, String bankAccountId, String description);
  Future<Map<String, dynamic>> fetchTransactionDetail(String id);
  Future<TraceabilityMetricsModel> getTraceabilityMetrics(String remittanceId);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final http.Client client;

  TransactionRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<void> deposit(double amount, String currency, String cardId, String description) async {
    final token = SessionManager.instance.token;
    if (token == null) throw Exception('No session token available');

    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiPrefix}/accounts/deposit');

    final body = {
      'amount': amount,
      'currency': currency,
      'cardId': cardId,
      'description': description,
    };

    final response = await client.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'X-User-Id': SessionManager.instance.userId ?? '',
        'X-Idempotency-Key': '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      String message = 'Error en el depósito (Status: ${response.statusCode})';
      try {
        if (response.body.isNotEmpty) {
          final json = jsonDecode(utf8.decode(response.bodyBytes));
          if (json is Map && json['message'] != null) {
            message = json['message'].toString();
          }
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  @override
  Future<void> withdraw(double amount, String currency, String bankAccountId, String description) async {
    final token = SessionManager.instance.token;
    if (token == null) throw Exception('No session token available');

    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiPrefix}/accounts/withdraw');

    final body = {
      'amount': amount,
      'currency': currency,
      'bankAccountId': bankAccountId,
      'description': description,
    };

    final response = await client.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'X-User-Id': SessionManager.instance.userId ?? '',
        'X-Idempotency-Key': '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      String message = 'Error en el retiro (Status: ${response.statusCode})';
      try {
        if (response.body.isNotEmpty) {
          final json = jsonDecode(utf8.decode(response.bodyBytes));
          if (json is Map && json['message'] != null) {
            message = json['message'].toString();
          }
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  @override
  Future<Map<String, dynamic>> fetchTransactionDetail(String id) async {
    final token = SessionManager.instance.token;
    final userId = SessionManager.instance.userId;
    if (token == null || userId == null) throw Exception('No session token available');

    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.userMovementsEndpoint(userId)}');

    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final movement = data.firstWhere((m) => m['transactionId'] == id, orElse: () => null);
      if (movement != null) {
        return movement as Map<String, dynamic>;
      } else {
        throw Exception('Transacción no encontrada');
      }
    } else {
      throw Exception('Failed to load movements: ${response.statusCode}');
    }
  }

  @override
  Future<TraceabilityMetricsModel> getTraceabilityMetrics(String remittanceId) async {
    // Note: The metrics endpoint is on the web3-remittance-service running on port 3001
    // We construct the URL directly or assume the API Gateway routes it.
    // Assuming API gateway routes /api/v1/metrics/traceability to the web3 service
    final url = Uri.parse('${AppConstants.baseUrl}/api/v1/metrics/traceability/$remittanceId');
    
    // Some endpoints might not need auth, but we'll send it anyway
    final token = SessionManager.instance.token;
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return TraceabilityMetricsModel.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load traceability metrics: ${response.statusCode}');
    }
  }
}
