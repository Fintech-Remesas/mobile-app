import 'dart:math';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../features/history/data/models/history_item_model.dart';
import '../../features/home/data/models/transaction_preview_model.dart';
import '../../features/home/data/models/wallet_summary_model.dart';
import '../../features/transactions/data/models/contact_model.dart';
import '../../features/transactions/data/models/transaction_detail_model.dart';

class RemittanceResponseModel {
  final String id;
  final String? quoteId;
  final String status;
  final Map<String, dynamic>? destBankAccount;
  final String? createdAt;
  final String? updatedAt;

  const RemittanceResponseModel({
    required this.id,
    this.quoteId,
    required this.status,
    this.destBankAccount,
    this.createdAt,
    this.updatedAt,
  });

  factory RemittanceResponseModel.fromJson(Map<String, dynamic> json) {
    return RemittanceResponseModel(
      id: json['id'] as String? ?? json['remittanceId'] as String? ?? '',
      quoteId: json['quoteId'] as String?,
      status: json['status'] as String? ?? 'UNKNOWN',
      destBankAccount: json['destBankAccount'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  String get beneficiaryName =>
      destBankAccount?['beneficiaryName'] as String? ?? 'Remittance';

  DateTime? get createdDateTime =>
      createdAt != null ? DateTime.tryParse(createdAt!) : null;
}

class QuoteResponseModel {
  final String id;
  final double sourceAmount;
  final double destAmount;
  final String sourceCurrency;
  final String destCurrency;

  const QuoteResponseModel({
    required this.id,
    required this.sourceAmount,
    required this.destAmount,
    required this.sourceCurrency,
    required this.destCurrency,
  });

  factory QuoteResponseModel.fromJson(Map<String, dynamic> json) {
    return QuoteResponseModel(
      id: json['id'] as String,
      sourceAmount: (json['sourceAmount'] as num).toDouble(),
      destAmount: (json['destAmount'] as num).toDouble(),
      sourceCurrency: json['sourceCurrency'] as String? ?? 'USD',
      destCurrency: json['destCurrency'] as String? ?? 'PEN',
    );
  }
}

class PageResponseModel<T> {
  final List<T> content;
  final int totalElements;

  const PageResponseModel({
    required this.content,
    required this.totalElements,
  });
}

class OrderTimelineModel {
  final String? txHash;
  final int? blockNumber;
  final String? currentStatus;
  final String? explorerUrl;

  const OrderTimelineModel({
    this.txHash,
    this.blockNumber,
    this.currentStatus,
    this.explorerUrl,
  });

  factory OrderTimelineModel.fromJson(Map<String, dynamic> json) {
    return OrderTimelineModel(
      txHash: json['txHash'] as String?,
      blockNumber: json['blockNumber'] as int?,
      currentStatus: json['currentStatus'] as String?,
      explorerUrl: json['explorerUrl'] as String?,
    );
  }
}

class TxTrackModel {
  final String txHash;
  final String status;
  final int? blockNumber;
  final String? timestamp;
  final String? explorerUrl;

  const TxTrackModel({
    required this.txHash,
    required this.status,
    this.blockNumber,
    this.timestamp,
    this.explorerUrl,
  });

  factory TxTrackModel.fromJson(Map<String, dynamic> json) {
    return TxTrackModel(
      txHash: json['txHash'] as String,
      status: json['status'] as String? ?? 'pending',
      blockNumber: json['blockNumber'] as int?,
      timestamp: json['timestamp'] as String?,
      explorerUrl: json['explorerUrl'] as String?,
    );
  }
}

abstract class RemittanceRemoteDataSource {
  Future<WalletSummaryModel> fetchWalletSummary();
  Future<List<TransactionPreviewModel>> fetchRecentTransactions();
  Future<List<HistoryItemModel>> fetchHistory();
  Future<TransactionDetailModel> fetchTransactionDetail(String id);
  Future<List<ContactModel>> searchContacts(String query);
  Future<String> sendRemittance({
    required String beneficiaryName,
    required double amount,
  });
}

class RemittanceRemoteDataSourceImpl implements RemittanceRemoteDataSource {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  final _random = Random();

  RemittanceRemoteDataSourceImpl({
    required this.apiClient,
    required this.tokenStorage,
  });

  String _newIdempotencyKey(String prefix) {
    final suffix = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final rand = _random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return '$prefix-$suffix-$rand';
  }

  Future<String> _requireUserId() async {
    final keycloakUserId = await tokenStorage.getKeycloakUserId();
    if (keycloakUserId != null && keycloakUserId.isNotEmpty) {
      return keycloakUserId;
    }

    final userId = await tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw const ApiException('User not authenticated');
    }
    return userId;
  }

  Future<PageResponseModel<RemittanceResponseModel>> _fetchUserRemittances({
    int page = 0,
    int size = 10,
  }) async {
    final userId = await _requireUserId();
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/v1/remittances/user/$userId',
      queryParameters: {'page': page, 'size': size},
    );

    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty remittances response');
    }

    final rawList = (body['content'] as List<dynamic>?) ??
        (body['remittances'] as List<dynamic>?) ??
        [];

    final items = rawList
        .map((e) => RemittanceResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PageResponseModel(
      content: items,
      totalElements: (body['totalElements'] as num?)?.toInt() ?? items.length,
    );
  }

  Future<QuoteResponseModel?> _fetchQuote(String quoteId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/quotes/$quoteId',
      );
      final body = response.data;
      if (body == null) return null;
      return QuoteResponseModel.fromJson(body);
    } catch (_) {
      return null;
    }
  }

  Future<double> _resolveOutgoingAmount(RemittanceResponseModel item) async {
    final quoteId = item.quoteId;
    if (quoteId == null || quoteId.isEmpty) return 0;

    final quote = await _fetchQuote(quoteId);
    if (quote == null) return 0;
    return -quote.sourceAmount;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<TransactionPreviewModel> _toPreview(RemittanceResponseModel item) async {
    final amount = await _resolveOutgoingAmount(item);
    return TransactionPreviewModel(
      id: item.id,
      title: item.beneficiaryName,
      subtitle: _formatDate(item.createdDateTime),
      amount: amount,
      isOutgoing: true,
    );
  }

  Future<HistoryItemModel> _toHistory(RemittanceResponseModel item) async {
    final amount = await _resolveOutgoingAmount(item);
    return HistoryItemModel(
      id: item.id,
      title: item.beneficiaryName,
      subtitle: _formatDate(item.createdDateTime),
      amount: amount,
      isOutgoing: true,
    );
  }

  Future<QuoteResponseModel> _createQuote({required double sourceAmount}) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/v1/quotes',
      data: {
        'sourceCurrency': 'USD',
        'destCurrency': 'PEN',
        'sourceAmount': sourceAmount,
      },
      headers: {'X-Idempotency-Key': _newIdempotencyKey('quote')},
    );

    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty quote response');
    }
    return QuoteResponseModel.fromJson(body);
  }

  Future<RemittanceResponseModel> _createRemittance({
    required String quoteId,
    required Map<String, dynamic> destBankAccount,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/v1/remittances',
      data: {
        'quoteId': quoteId,
        'destBankAccount': destBankAccount,
      },
      headers: {'X-Idempotency-Key': _newIdempotencyKey('remittance')},
    );

    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty remittance response');
    }
    return RemittanceResponseModel.fromJson(body);
  }

  @override
  Future<String> sendRemittance({
    required String beneficiaryName,
    required double amount,
  }) async {
    final quote = await _createQuote(sourceAmount: amount);
    final remittance = await _createRemittance(
      quoteId: quote.id,
      destBankAccount: {
        'bankName': 'BCP',
        'accountNumber': '194-12345678-0-12',
        'accountType': 'SAVINGS',
        'beneficiaryName': beneficiaryName,
        'country': 'PE',
      },
    );
    return remittance.id;
  }

  @override
  Future<WalletSummaryModel> fetchWalletSummary() async {
    final page = await _fetchUserRemittances(page: 0, size: 1);
    return WalletSummaryModel(
      balance: page.totalElements.toDouble(),
      currency: 'COUNT',
    );
  }

  @override
  Future<List<TransactionPreviewModel>> fetchRecentTransactions() async {
    final page = await _fetchUserRemittances(page: 0, size: 5);
    return Future.wait(page.content.map(_toPreview));
  }

  @override
  Future<List<HistoryItemModel>> fetchHistory() async {
    final page = await _fetchUserRemittances(page: 0, size: 20);
    return Future.wait(page.content.map(_toHistory));
  }

  Future<OrderTimelineModel?> _fetchTimeline(String id) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/orders/$id/timeline',
      );
      final body = response.data;
      if (body == null) return null;
      return OrderTimelineModel.fromJson(body);
    } catch (_) {
      return null;
    }
  }

  Future<TxTrackModel?> _fetchTxTrack(String txHash) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/tx/$txHash/track',
      );
      final body = response.data;
      if (body == null) return null;
      return TxTrackModel.fromJson(body);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<TransactionDetailModel> fetchTransactionDetail(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/v1/remittances/$id',
    );
    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty remittance detail response');
    }

    final remittance = RemittanceResponseModel.fromJson(body);
    final amount = await _resolveOutgoingAmount(remittance);
    final timeline = await _fetchTimeline(id);

    String? txHash = timeline?.txHash;
    int blockNumber = timeline?.blockNumber ?? 0;
    String confirmationStatus = 'pending';
    DateTime blockTimestamp = remittance.createdDateTime ?? DateTime.now();
    String? polygonscanUrl = timeline?.explorerUrl;

    if (txHash != null && txHash.isNotEmpty) {
      final track = await _fetchTxTrack(txHash);
      if (track != null) {
        blockNumber = track.blockNumber ?? blockNumber;
        confirmationStatus =
            track.status == 'confirmed' ? 'confirmed' : 'pending';
        blockTimestamp = track.timestamp != null
            ? DateTime.parse(track.timestamp!)
            : blockTimestamp;
        polygonscanUrl ??= track.explorerUrl;
      }
    } else {
      txHash =
          '0x0000000000000000000000000000000000000000000000000000000000000000';
      confirmationStatus = remittance.status.contains('CONFIRM') ||
              remittance.status.contains('COMPLETED')
          ? 'confirmed'
          : 'pending';
    }

    return TransactionDetailModel(
      id: remittance.id,
      amount: amount,
      status: remittance.status,
      recipient: remittance.beneficiaryName,
      transactionHash: txHash,
      network: 'amoyTestnet',
      blockNumber: blockNumber,
      confirmationStatus: confirmationStatus,
      blockTimestamp: blockTimestamp,
      polygonscanUrl: polygonscanUrl,
    );
  }

  @override
  Future<List<ContactModel>> searchContacts(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/v1/users/search',
      queryParameters: {'query': query, 'type': 'name', 'page': 0, 'size': 20},
    );

    final body = response.data;
    if (body == null) return [];

    final data = body['data'] as Map<String, dynamic>? ?? body;
    final users = data['users'] as List<dynamic>? ?? [];

    return users.map((user) {
      final map = user as Map<String, dynamic>;
      final firstName = map['firstName'] as String? ?? '';
      final lastName = map['lastName'] as String? ?? '';
      final name = '$firstName $lastName'.trim();
      return ContactModel(
        id: map['id']?.toString() ?? '',
        name: name.isEmpty ? (map['username'] as String? ?? 'User') : name,
        phone: map['phone'] as String? ?? '',
      );
    }).toList();
  }
}
