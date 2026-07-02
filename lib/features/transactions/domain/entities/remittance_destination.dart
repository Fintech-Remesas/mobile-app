import 'package:equatable/equatable.dart';

class RemittanceDestination extends Equatable {
  final String destinationUserId;
  final String destinationBankAccountId;
  final String destinationWalletAddress;
  final String? note;

  const RemittanceDestination({
    required this.destinationUserId,
    required this.destinationBankAccountId,
    required this.destinationWalletAddress,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'destinationUserId': destinationUserId,
        'destinationBankAccountId': destinationBankAccountId,
        'destinationWalletAddress': destinationWalletAddress,
        if (note != null && note!.isNotEmpty) 'note': note,
      };

  @override
  List<Object?> get props => [
        destinationUserId,
        destinationBankAccountId,
        destinationWalletAddress,
        note,
      ];
}
