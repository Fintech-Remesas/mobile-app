import 'dart:math';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/utils/remittance_status_mapper.dart';
import '../../features/history/data/models/history_item_model.dart';
import '../../features/history/domain/entities/history_page.dart';
import '../../features/home/data/models/transaction_preview_model.dart';
import '../../features/home/data/models/wallet_summary_model.dart';
import '../../features/transactions/data/models/contact_model.dart';
import '../../features/transactions/data/models/transaction_detail_model.dart';
import '../../features/transactions/domain/entities/quote.dart';
import '../../features/transactions/domain/entities/remittance.dart';
import '../../features/transactions/domain/entities/remittance_destination.dart';
import '../../features/transactions/domain/entities/timeline_step.dart';
import '../../features/transactions/domain/entities/transaction_detail.dart';

class QuoteResponseModel {
  final String id;
  final double sourceAmount;
  final double destAmount;
  final String sourceCurrency;
  final String destCurrency;
  final double? exchangeRate;
  final double? platformFee;
  final DateTime? expiresAt;
  final String? status;

  const QuoteResponseModel({
    required this.id,
    required this.sourceAmount,
    required this.destAmount,
    required this.sourceCurrency,
    required this.destCurrency,
    this.exchangeRate,
    this.platformFee,
    this.expiresAt,
    this.status,
  });

  factory QuoteResponseModel.fromJson(Map<String, dynamic> json) {
    return QuoteResponseModel(
      id: json['id'] as String? ?? json['quoteId'] as String? ?? '',
      sourceAmount: (json['sourceAmount'] as num?)?.toDouble() ??
          (json['amountUSD'] as num?)?.toDouble() ??
          0,
      destAmount: (json['destAmount'] as num?)?.toDouble() ??
          (json['amountDestination'] as num?)?.toDouble() ??
          0,
      sourceCurrency: json['sourceCurrency'] as String? ?? 'USD',
      destCurrency: json['destCurrency'] as String? ??
          json['destinationCurrency'] as String? ??
          'USD',
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
      platformFee: (json['platformFee'] as num?)?.toDouble() ??
          (json['feeAmount'] as num?)?.toDouble(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      status: json['status'] as String?,
    );
  }

  Quote toEntity() => Quote(
        id: id,
        sourceAmount: sourceAmount,
        destAmount: destAmount,
        sourceCurrency: sourceCurrency,
        destCurrency: destCurrency,
        exchangeRate: exchangeRate,
        platformFee: platformFee,
        expiresAt: expiresAt,
        status: status,
      );
}

class RemittanceResponseModel {
  final String id;
  final String? quoteId;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final String? depositCode;
  final double? amountUSD;
  final double? feeAmount;
  final double? amountSourceCurrency;
  final double? simulatedAmountPEN;
  final double? amountDestination;
  final String? message;
  final String? expiresAt;
  final String? txHash;
  final String? explorerUrl;
  final int? blockNumber;
  final String? errorMessage;
  final List<TimelineStepModel> ledgerTimeline;

  const RemittanceResponseModel({
    required this.id,
    this.quoteId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.depositCode,
    this.amountUSD,
    this.feeAmount,
    this.amountSourceCurrency,
    this.simulatedAmountPEN,
    this.amountDestination,
    this.message,
    this.expiresAt,
    this.txHash,
    this.explorerUrl,
    this.blockNumber,
    this.errorMessage,
    this.ledgerTimeline = const [],
  });

  factory RemittanceResponseModel.fromJson(Map<String, dynamic> json) {
    final rawTimeline = json['timeline'] as List<dynamic>? ?? [];
    return RemittanceResponseModel(
      id: json['id'] as String? ?? json['remittanceId'] as String? ?? '',
      quoteId: json['quoteId'] as String?,
      status: json['status'] as String? ?? 'UNKNOWN',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      depositCode: json['depositCode'] as String?,
      amountUSD: (json['amountUSD'] as num?)?.toDouble(),
      feeAmount: (json['feeAmount'] as num?)?.toDouble(),
      amountSourceCurrency: (json['amountSourceCurrency'] as num?)?.toDouble(),
      simulatedAmountPEN: (json['simulatedAmountPEN'] as num?)?.toDouble(),
      amountDestination: (json['amountDestination'] as num?)?.toDouble(),
      message: json['message'] as String?,
      expiresAt: json['expiresAt'] as String?,
      txHash: json['txHash'] as String?,
      explorerUrl: json['explorerUrl'] as String?,
      blockNumber: (json['blockNumber'] as num?)?.toInt(),
      errorMessage: json['errorMessage'] as String?,
      ledgerTimeline: rawTimeline
          .map((e) => TimelineStepModel.fromLedgerJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  DateTime? get createdDateTime =>
      createdAt != null ? DateTime.tryParse(createdAt!) : null;

  Remittance toEntity() => Remittance(
        id: id,
        quoteId: quoteId,
        status: status,
        depositCode: depositCode,
        amountUSD: amountUSD,
        feeAmount: feeAmount,
        amountSourceCurrency: amountSourceCurrency,
        simulatedAmountPEN: simulatedAmountPEN,
        amountDestination: amountDestination,
        message: message,
        expiresAt: expiresAt,
        txHash: txHash,
        explorerUrl: explorerUrl,
        blockNumber: blockNumber,
        errorMessage: errorMessage,
        createdAt: createdAt,
      );
}

class PageResponseModel<T> {
  final List<T> content;
  final int totalElements;
  final int page;
  final int size;
  final RemittanceSummary? summary;

  const PageResponseModel({
    required this.content,
    required this.totalElements,
    this.page = 0,
    this.size = 20,
    this.summary,
  });
}

class TimelineStepModel {
  final int step;
  final String label;
  final String status;
  final String? timestamp;
  final String? detail;
  final String? txHash;
  final String? explorerUrl;
  final int? blockNumber;

  const TimelineStepModel({
    required this.step,
    required this.label,
    required this.status,
    this.timestamp,
    this.detail,
    this.txHash,
    this.explorerUrl,
    this.blockNumber,
  });

  factory TimelineStepModel.fromJson(Map<String, dynamic> json) {
    return TimelineStepModel(
      step: (json['step'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      timestamp: json['timestamp'] as String?,
      detail: json['detail'] as String?,
      txHash: json['txHash'] as String?,
      explorerUrl: json['explorerUrl'] as String?,
      blockNumber: (json['blockNumber'] as num?)?.toInt(),
    );
  }

  factory TimelineStepModel.fromLedgerJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? '';
    final label = json['label'] as String? ?? rawStatus;
    return TimelineStepModel(
      step: (json['step'] as num?)?.toInt() ?? 0,
      label: label,
      status: _mapLedgerStepStatus(rawStatus),
      timestamp: json['timestamp'] as String?,
      detail: json['detail'] as String?,
      txHash: json['txHash'] as String?,
      explorerUrl: json['explorerUrl'] as String?,
      blockNumber: (json['blockNumber'] as num?)?.toInt(),
    );
  }

  static String _mapLedgerStepStatus(String status) {
    final upper = status.toUpperCase();
    if (upper.contains('COMPLETED') ||
        upper.contains('CONFIRMED') ||
        upper.contains('DEPOSIT_CONFIRMED')) {
      return 'completed';
    }
    if (upper.contains('PROGRESS') ||
        upper.contains('BLOCKCHAIN') ||
        upper.contains('PAYOUT')) {
      return 'in_progress';
    }
    return 'pending';
  }

  TimelineStep toEntity() => TimelineStep(
        step: step,
        label: label,
        status: status,
        timestamp: timestamp,
        detail: detail,
        txHash: txHash,
        explorerUrl: explorerUrl,
        blockNumber: blockNumber,
      );
}

class OrderTimelineModel {
  final String? txHash;
  final int? blockNumber;
  final String? currentStatus;
  final String? explorerUrl;
  final List<TimelineStepModel> steps;

  const OrderTimelineModel({
    this.txHash,
    this.blockNumber,
    this.currentStatus,
    this.explorerUrl,
    this.steps = const [],
  });

  factory OrderTimelineModel.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] as List<dynamic>? ?? [];
    return OrderTimelineModel(
      txHash: json['txHash'] as String?,
      blockNumber: (json['blockNumber'] as num?)?.toInt(),
      currentStatus: json['currentStatus'] as String?,
      explorerUrl: json['explorerUrl'] as String?,
      steps: rawSteps
          .map((e) => TimelineStepModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TxTrackModel {
  final String txHash;
  final String status;
  final int? blockNumber;
  final String? timestamp;
  final String? explorerUrl;
  final int? confirmations;

  const TxTrackModel({
    required this.txHash,
    required this.status,
    this.blockNumber,
    this.timestamp,
    this.explorerUrl,
    this.confirmations,
  });

  factory TxTrackModel.fromJson(Map<String, dynamic> json) {
    return TxTrackModel(
      txHash: json['txHash'] as String,
      status: json['status'] as String? ?? 'pending',
      blockNumber: (json['blockNumber'] as num?)?.toInt(),
      timestamp: json['timestamp'] as String?,
      explorerUrl: json['explorerUrl'] as String?,
      confirmations: (json['confirmations'] as num?)?.toInt(),
    );
  }
}

class TxStatusModel {
  final String txHash;
  final String status;
  final int? confirmations;

  const TxStatusModel({
    required this.txHash,
    required this.status,
    this.confirmations,
  });

  factory TxStatusModel.fromJson(Map<String, dynamic> json) {
    return TxStatusModel(
      txHash: json['txHash'] as String,
      status: json['status'] as String? ?? 'pending',
      confirmations: (json['confirmations'] as num?)?.toInt(),
    );
  }
}

abstract class RemittanceRemoteDataSource {
  Future<WalletSummaryModel> fetchWalletSummary();
  Future<List<TransactionPreviewModel>> fetchRecentTransactions();
  Future<HistoryPage> fetchHistoryPage({int page = 0, int size = 20});
  Future<TransactionDetail> fetchTransactionDetail(String id);
  Future<List<ContactModel>> searchContacts(String query);
  Future<Quote> createQuote({
    required double sourceAmount,
    String destinationCountry = 'PE',
  });
  Future<Remittance> createRemittance({
    required String quoteId,
    required RemittanceDestination destination,
  });
  Future<Remittance> fetchRemittance(String id);
  Future<void> confirmDeposit(String remittanceId);
  Future<TxStatusModel?> fetchTxStatus(String txHash);
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

  RemittanceSummary? _parseSummary(Map<String, dynamic>? raw) {
    if (raw == null) return null;
    return RemittanceSummary(
      totalAmountUSD: (raw['totalAmountUSD'] as num?)?.toDouble() ?? 0,
      totalTransactions: (raw['totalTransactions'] as num?)?.toInt() ?? 0,
      completedCount: (raw['completedCount'] as num?)?.toInt() ?? 0,
      failedCount: (raw['failedCount'] as num?)?.toInt() ?? 0,
    );
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
      totalElements: (body['total'] as num?)?.toInt() ??
          (body['totalElements'] as num?)?.toInt() ??
          items.length,
      page: (body['page'] as num?)?.toInt() ?? page,
      size: (body['size'] as num?)?.toInt() ?? size,
      summary: _parseSummary(body['summary'] as Map<String, dynamic>?),
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
    if (item.amountUSD != null) return -item.amountUSD!;

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
      title: 'Remesa ${item.depositCode ?? item.id.substring(0, 8)}',
      subtitle: _formatDate(item.createdDateTime),
      amount: amount,
      isOutgoing: true,
    );
  }

  Future<HistoryItemModel> _toHistory(RemittanceResponseModel item) async {
    final amount = await _resolveOutgoingAmount(item);
    return HistoryItemModel(
      id: item.id,
      title: 'Remesa ${item.depositCode ?? item.id.substring(0, 8)}',
      subtitle: _formatDate(item.createdDateTime),
      amount: amount,
      isOutgoing: true,
    );
  }

  List<TimelineStep> _mergeTimelines(
    List<TimelineStepModel> web3Steps,
    List<TimelineStepModel> ledgerSteps,
  ) {
    if (web3Steps.isNotEmpty) {
      return web3Steps.map((s) => s.toEntity()).toList();
    }
    if (ledgerSteps.isNotEmpty) {
      return ledgerSteps.map((s) => s.toEntity()).toList();
    }
    return [];
  }

  @override
  Future<Quote> createQuote({
    required double sourceAmount,
    String destinationCountry = 'PE',
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/v1/quotes',
      data: {
        'sourceCurrency': 'USD',
        'destCurrency': 'USD',
        'destinationCountry': destinationCountry,
        'amountUSD': sourceAmount,
      },
      headers: {'X-Idempotency-Key': _newIdempotencyKey('quote')},
    );

    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty quote response');
    }
    return QuoteResponseModel.fromJson(body).toEntity();
  }

  Future<RemittanceResponseModel> _createRemittanceRaw({
    required String quoteId,
    required RemittanceDestination destination,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/v1/remittances',
      data: {
        'quoteId': quoteId,
        ...destination.toJson(),
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
  Future<Remittance> createRemittance({
    required String quoteId,
    required RemittanceDestination destination,
  }) async {
    final raw = await _createRemittanceRaw(
      quoteId: quoteId,
      destination: destination,
    );
    return raw.toEntity();
  }

  @override
  Future<Remittance> fetchRemittance(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/v1/remittances/$id',
    );
    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty remittance detail response');
    }
    return RemittanceResponseModel.fromJson(body).toEntity();
  }

  @override
  Future<void> confirmDeposit(String remittanceId) async {
    await apiClient.post<void>(
      '/api/v1/remittances/$remittanceId/confirm-deposit',
    );
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
  Future<HistoryPage> fetchHistoryPage({int page = 0, int size = 20}) async {
    final result = await _fetchUserRemittances(page: page, size: size);
    final items = await Future.wait(result.content.map(_toHistory));
    return HistoryPage(
      items: items,
      total: result.totalElements,
      page: result.page,
      size: result.size,
      summary: result.summary,
    );
  }

  Future<OrderTimelineModel?> _fetchTimeline(String id) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/orders/$id/timeline',
      );
      final body = response.data;
      if (body == null) return null;
      return OrderTimelineModel.fromJson(body);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
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
  Future<TxStatusModel?> fetchTxStatus(String txHash) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/tx/$txHash/status',
      );
      final body = response.data;
      if (body == null) return null;
      return TxStatusModel.fromJson(body);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<TransactionDetail> fetchTransactionDetail(String id) async {
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

    String? txHash = timeline?.txHash ?? remittance.txHash;
    int blockNumber = timeline?.blockNumber ?? remittance.blockNumber ?? 0;
    String confirmationStatus = 'pending';
    DateTime blockTimestamp = remittance.createdDateTime ?? DateTime.now();
    String? polygonscanUrl = timeline?.explorerUrl ?? remittance.explorerUrl;

    if (txHash != null && txHash.isNotEmpty) {
      final track = await _fetchTxTrack(txHash);
      if (track != null) {
        blockNumber = track.blockNumber ?? blockNumber;
        confirmationStatus =
            track.status == 'confirmed' ? 'confirmed' : track.status;
        blockTimestamp = track.timestamp != null
            ? DateTime.parse(track.timestamp!)
            : blockTimestamp;
        polygonscanUrl ??= track.explorerUrl;
      }
    } else {
      txHash = null;
      confirmationStatus = remittance.status.contains('CONFIRM') ||
              remittance.status.contains('COMPLETED')
          ? 'confirmed'
          : 'pending';
    }

    final steps = _mergeTimelines(
      timeline?.steps ?? [],
      remittance.ledgerTimeline,
    );

    return TransactionDetailModel(
      id: remittance.id,
      amount: amount,
      status: remittance.status,
      statusLabel: RemittanceStatusMapper.label(remittance.status),
      recipient: 'Remesa ${remittance.depositCode ?? remittance.id.substring(0, 8)}',
      transactionHash: txHash,
      network: 'amoyTestnet',
      blockNumber: blockNumber,
      confirmationStatus: confirmationStatus,
      blockTimestamp: blockTimestamp,
      polygonscanUrl: polygonscanUrl,
      depositCode: remittance.depositCode,
      amountSourceCurrency:
          remittance.simulatedAmountPEN ?? remittance.amountSourceCurrency,
      errorMessage: remittance.errorMessage,
      timelineSteps: steps,
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

    return users
        .map((user) => ContactModel.fromJson(user as Map<String, dynamic>))
        .toList();
  }
}
