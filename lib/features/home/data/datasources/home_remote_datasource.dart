import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/session_manager.dart';
import '../models/wallet_summary_model.dart';
import '../models/ledger_movement_model.dart';

abstract class HomeRemoteDataSource {
  Future<WalletSummaryModel> fetchWalletSummary(String userId);
  Future<List<LedgerMovementModel>> fetchMovements(String userId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final http.Client client;

  HomeRemoteDataSourceImpl({required this.client});

  Map<String, String> get _authHeaders {
    final token = SessionManager.instance.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String get _resolvedUserId =>
      SessionManager.instance.userId ?? '';

  @override
  Future<WalletSummaryModel> fetchWalletSummary(String userId) async {
    final id = _resolvedUserId.isNotEmpty ? _resolvedUserId : userId;
    final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.accountCalculatedBalanceEndpoint(id)}');
    print('[HomeRemote] Balance request: $url');

    final response = await client.get(url, headers: _authHeaders);
    print('[HomeRemote] Balance response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WalletSummaryModel(
        balance: _parseDouble(data['balance']),
        currency: 'USD',
      );
    } else {
      throw Exception(
          'Failed to load wallet summary: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<List<LedgerMovementModel>> fetchMovements(String userId) async {
    final id = _resolvedUserId.isNotEmpty ? _resolvedUserId : userId;
    final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.userMovementsEndpoint(id)}');
    print('[HomeRemote] Movements request: $url');

    final response = await client.get(url, headers: _authHeaders);
    print('[HomeRemote] Movements response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) =>
              LedgerMovementModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
          'Failed to load movements: ${response.statusCode} - ${response.body}');
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
