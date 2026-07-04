class TxTrackModel {
  final String txHash;
  final String status; // pending, confirmed, failed
  final int? blockNumber;
  final int confirmations;
  final String? explorerUrl;
  final String? from;
  final String? to;
  final String? value;
  final String? gasUsed;
  final DateTime? timestamp;

  TxTrackModel({
    required this.txHash,
    required this.status,
    this.blockNumber,
    required this.confirmations,
    this.explorerUrl,
    this.from,
    this.to,
    this.value,
    this.gasUsed,
    this.timestamp,
  });

  factory TxTrackModel.fromJson(Map<String, dynamic> json) {
    return TxTrackModel(
      txHash: json['txHash'] ?? '',
      status: json['status'] ?? 'pending',
      blockNumber: json['blockNumber'],
      confirmations: json['confirmations'] ?? 0,
      explorerUrl: json['explorerUrl'],
      from: json['from'],
      to: json['to'],
      value: json['value'],
      gasUsed: json['gasUsed'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }
}

class WalletInfoModel {
  final String address;
  final double balanceUSDC;
  final double balanceMATIC;
  final String network;
  final String explorerUrl;

  WalletInfoModel({
    required this.address,
    required this.balanceUSDC,
    required this.balanceMATIC,
    required this.network,
    required this.explorerUrl,
  });

  factory WalletInfoModel.fromJson(Map<String, dynamic> json) {
    return WalletInfoModel(
      address: json['address'] ?? '',
      balanceUSDC: (json['balanceUSDC'] ?? 0).toDouble(),
      balanceMATIC: (json['balanceMATIC'] ?? 0).toDouble(),
      network: json['network'] ?? '',
      explorerUrl: json['explorerUrl'] ?? '',
    );
  }
}
