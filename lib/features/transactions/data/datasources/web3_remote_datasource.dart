import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/session_manager.dart';
import '../models/web3/user_search_model.dart';
import '../models/web3/quote_model.dart';
import '../models/web3/remittance_model.dart';
import '../models/web3/timeline_model.dart';
import '../models/web3/tx_track_model.dart';

abstract class Web3RemoteDataSource {
  Future<List<UserSearchModel>> searchUsers(String query);
  Future<UserSearchModel> fetchPublicProfile(String userId);
  Future<QuoteModel> createQuote(double amountUSD, {required String destinationCountry});
  Future<RemittanceModel> createRemittance(
    String quoteId,
    String destinationUserId,
    String? destinationBankAccountId,
    String? destinationWalletAddress,
    String? senderName,
    String? recipientName,
    String note, {
    String? senderCountry,
    required String recipientCountry,
  });
  Future<void> confirmDeposit(String remittanceId);
  Future<TimelineModel> getTimeline(String remittanceId);
  Future<TxTrackModel> trackTx(String txHash);
  Future<WalletInfoModel> getWalletInfo();
}

class Web3RemoteDataSourceImpl implements Web3RemoteDataSource {
  final http.Client client;

  Web3RemoteDataSourceImpl({required this.client});

  Map<String, String> _buildHeaders({String? idempotencyKey}) {
    final token = SessionManager.instance.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (idempotencyKey != null) 'X-Idempotency-Key': idempotencyKey,
    };
  }

  String _extractError(http.Response response, String fallback) {
    try {
      final body = json.decode(response.body);
      if (body is Map) {
        return body['message']?.toString() ??
            body['error']?.toString() ??
            body['detail']?.toString() ??
            '$fallback (${response.statusCode}): ${response.body}';
      }
    } catch (_) {}
    return '$fallback (${response.statusCode}): ${response.body}';
  }

  @override
  Future<List<UserSearchModel>> searchUsers(String query) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiPrefix}/users/search?query=$query');
    final response = await client.get(url, headers: _buildHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final dynamic data = jsonResponse['data'] ?? jsonResponse;
      List<dynamic> usersList = [];
      if (data is List) {
        usersList = data;
      } else if (data is Map && data['users'] != null) {
        usersList = data['users'];
      } else if (data is Map && data['content'] != null) {
        usersList = data['content'];
      }
      return usersList.map((e) => UserSearchModel.fromJson(e)).toList();
    } else {
      throw Exception(_extractError(response, 'Error al buscar usuarios'));
    }
  }

  @override
  Future<UserSearchModel> fetchPublicProfile(String userId) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiPrefix}/users/$userId/public-profile');
    final response = await client.get(url, headers: _buildHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'] ?? jsonResponse;
      return UserSearchModel.fromJson(data as Map<String, dynamic>);
    }
    throw Exception(_extractError(response, 'No se pudo obtener el perfil del destinatario'));
  }

  @override
  Future<QuoteModel> createQuote(
    double amountUSD, {
    required String destinationCountry,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.quotesEndpoint}');
    final response = await client.post(
      url,
      headers: _buildHeaders(idempotencyKey: 'quote-req-${DateTime.now().millisecondsSinceEpoch}'),
      body: json.encode({
        'sourceCurrency': 'USD',
        'destCurrency': destinationCountry == 'PE' ? 'PEN' : 'USD',
        'destinationCountry': destinationCountry,
        'amountUSD': amountUSD,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return QuoteModel.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception(_extractError(response, 'Error al crear cotización'));
  }

  @override
  Future<RemittanceModel> createRemittance(
    String quoteId,
    String destinationUserId,
    String? destinationBankAccountId,
    String? destinationWalletAddress,
    String? senderName,
    String? recipientName,
    String note, {
    String? senderCountry,
    required String recipientCountry,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.remittancesEndpoint}');
    final body = <String, dynamic>{
      'quoteId': quoteId,
      'destinationUserId': destinationUserId,
      'recipientCountry': recipientCountry,
      'note': note,
    };
    if (senderCountry != null && senderCountry.isNotEmpty) {
      body['senderCountry'] = senderCountry;
    }
    if (destinationBankAccountId != null) {
      body['destinationBankAccountId'] = destinationBankAccountId;
    }
    if (destinationWalletAddress != null && destinationWalletAddress.isNotEmpty) {
      body['destinationWalletAddress'] = destinationWalletAddress;
    }
    if (senderName != null) {
      body['senderName'] = senderName;
    }
    if (recipientName != null) {
      body['recipientName'] = recipientName;
    }

    final response = await client.post(
      url,
      headers: _buildHeaders(idempotencyKey: 'remit-req-$quoteId'),
      body: json.encode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return RemittanceModel.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception(_extractError(response, 'Error al crear remesa'));
  }

  @override
  Future<void> confirmDeposit(String remittanceId) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.confirmDepositEndpoint(remittanceId)}');
    final response = await client.post(url, headers: _buildHeaders());

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_extractError(response, 'Error al confirmar pago con tarjeta'));
    }
  }

  @override
  Future<TimelineModel> getTimeline(String remittanceId) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.orderTimelineEndpoint(remittanceId)}');
    final response = await client.get(url, headers: _buildHeaders());

    if (response.statusCode == 200) {
      return TimelineModel.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception(_extractError(response, 'Error al obtener timeline'));
  }

  @override
  Future<TxTrackModel> trackTx(String txHash) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.trackTxEndpoint(txHash)}');
    final response = await client.get(url, headers: _buildHeaders());

    if (response.statusCode == 200) {
      return TxTrackModel.fromJson(json.decode(response.body));
    }
    throw Exception(_extractError(response, 'Error al rastrear transacción'));
  }

  @override
  Future<WalletInfoModel> getWalletInfo() async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.walletInfoEndpoint}');
    final response = await client.get(url, headers: _buildHeaders());

    if (response.statusCode == 200) {
      return WalletInfoModel.fromJson(json.decode(response.body));
    }
    throw Exception(_extractError(response, 'Error al obtener info de wallet'));
  }
}
