import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/session_manager.dart';

abstract class PaymentMethodsRemoteDataSource {
  Future<void> addCard({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cardBrand,
    required String cardType,
    String? alias,
  });

  Future<void> addBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountType,
    required String currency,
    required String country,
    String? alias,
  });

  Future<List<dynamic>> getCards();
  Future<void> deleteCard(String id);
  
  Future<List<dynamic>> getBankAccounts();
  Future<void> deleteBankAccount(String id);
}

class PaymentMethodsRemoteDataSourceImpl implements PaymentMethodsRemoteDataSource {
  final http.Client client;

  PaymentMethodsRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<void> addCard({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cardBrand,
    required String cardType,
    String? alias,
  }) async {
    final token = SessionManager.instance.token;
    if (token == null) throw Exception('No session token available');

    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiPrefix}/users/me/cards');

    final body = {
      'cardholderName': cardholderName,
      'cardNumber': cardNumber,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cardBrand': cardBrand,
      'cardType': cardType,
    };
    if (alias != null && alias.isNotEmpty) {
      body['alias'] = alias;
    }

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
      String message = 'Error adding card (Status: ${response.statusCode})';
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
  Future<void> addBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountType,
    required String currency,
    required String country,
    String? alias,
  }) async {
    final token = SessionManager.instance.token;
    if (token == null) throw Exception('No session token available');

    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiPrefix}/users/me/bank-accounts');

    final body = {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'currency': currency,
      'country': country,
    };
    if (alias != null && alias.isNotEmpty) {
      body['alias'] = alias;
    }

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
      String message = 'Error adding bank account (Status: ${response.statusCode})';
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
  Future<List<dynamic>> getCards() async {
    final token = SessionManager.instance.token;
    if (token == null) throw Exception('No session token available');

    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiPrefix}/users/me/cards');

    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return json['data'] ?? [];
    } else {
      throw Exception('Failed to load cards');
    }
  }

  @override
  Future<void> deleteCard(String id) async {
    final token = SessionManager.instance.token;
    if (token == null) throw Exception('No session token available');

    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiPrefix}/users/me/cards/$id');

    final response = await client.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete card');
    }
  }

  @override
  Future<List<dynamic>> getBankAccounts() async {
    final token = SessionManager.instance.token;
    if (token == null) throw Exception('No session token available');

    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiPrefix}/users/me/bank-accounts');

    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return json['data'] ?? [];
    } else {
      throw Exception('Failed to load bank accounts');
    }
  }

  @override
  Future<void> deleteBankAccount(String id) async {
    final token = SessionManager.instance.token;
    if (token == null) throw Exception('No session token available');

    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiPrefix}/users/me/bank-accounts/$id');

    final response = await client.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete bank account');
    }
  }
}
