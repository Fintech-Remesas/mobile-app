import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/session_manager.dart';
import '../../../home/data/models/ledger_movement_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<LedgerMovementModel>> fetchMovements(String userId);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final http.Client client;

  HistoryRemoteDataSourceImpl({required this.client});

  Map<String, String> get _authHeaders {
    final token = SessionManager.instance.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String get _resolvedUserId => SessionManager.instance.userId ?? '';

  @override
  Future<List<LedgerMovementModel>> fetchMovements(String userId) async {
    final id = _resolvedUserId.isNotEmpty ? _resolvedUserId : userId;
    final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.userMovementsEndpoint(id)}');

    final response = await client.get(url, headers: _authHeaders);

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
}
