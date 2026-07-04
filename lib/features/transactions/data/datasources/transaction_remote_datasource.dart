import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/session_manager.dart';

abstract class TransactionRemoteDataSource {
  Future<void> deposit(double amount, String currency, String cardId, String description);
  Future<void> withdraw(double amount, String currency, String bankAccountId, String description);
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
}
