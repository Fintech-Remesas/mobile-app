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
  Future<QuoteModel> createQuote(double amountUSD);
  Future<RemittanceModel> createRemittance(String quoteId, String destinationUserId, String destinationBankAccountId, String destinationWalletAddress, String note);
  Future<void> confirmDeposit(String remittanceId);
  Future<TimelineModel> getTimeline(String remittanceId);
  Future<TxTrackModel> trackTx(String txHash);
  Future<WalletInfoModel> getWalletInfo();
}

class Web3RemoteDataSourceImpl implements Web3RemoteDataSource {
  final http.Client client;

  Web3RemoteDataSourceImpl({required this.client});

  Map<String, String> get _authHeaders {
    final token = SessionManager.instance.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<UserSearchModel>> searchUsers(String query) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiPrefix}/users/search?query=$query');
    final response = await client.get(url, headers: _authHeaders);
    
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
      throw Exception('Failed to search users');
    }
  }

  @override
  Future<QuoteModel> createQuote(double amountUSD) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.quotesEndpoint}');
    final response = await client.post(
      url, 
      headers: _authHeaders,
      body: json.encode({
        "sourceCurrency": "USD",
        "destCurrency": "PEN",
        "destinationCountry": "PE",
        "amountUSD": amountUSD
      })
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return QuoteModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create quote');
    }
  }

  @override
  Future<RemittanceModel> createRemittance(String quoteId, String destinationUserId, String destinationBankAccountId, String destinationWalletAddress, String note) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.remittancesEndpoint}');
    final response = await client.post(
      url, 
      headers: _authHeaders,
      body: json.encode({
        "quoteId": quoteId,
        "destinationUserId": destinationUserId,
        "destinationBankAccountId": destinationBankAccountId,
        "destinationWalletAddress": destinationWalletAddress,
        "note": note
      })
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return RemittanceModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create remittance');
    }
  }

  @override
  Future<void> confirmDeposit(String remittanceId) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.confirmDepositEndpoint(remittanceId)}');
    final response = await client.post(url, headers: _authHeaders);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to confirm deposit');
    }
  }

  @override
  Future<TimelineModel> getTimeline(String remittanceId) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.orderTimelineEndpoint(remittanceId)}');
    final response = await client.get(url, headers: _authHeaders);

    if (response.statusCode == 200) {
      return TimelineModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get timeline');
    }
  }

  @override
  Future<TxTrackModel> trackTx(String txHash) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.trackTxEndpoint(txHash)}');
    final response = await client.get(url, headers: _authHeaders);

    if (response.statusCode == 200) {
      return TxTrackModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to track tx');
    }
  }

  @override
  Future<WalletInfoModel> getWalletInfo() async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.walletInfoEndpoint}');
    final response = await client.get(url, headers: _authHeaders);

    if (response.statusCode == 200) {
      return WalletInfoModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get wallet info');
    }
  }
}
