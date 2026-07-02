import 'dart:math';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_response_model.dart';
import '../models/bank_account_model.dart';

abstract class BankAccountRemoteDataSource {
  Future<BankAccountModel> addBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountType,
    required String currency,
    required String country,
    String? alias,
  });

  Future<List<BankAccountModel>> getBankAccounts();

  Future<void> deleteBankAccount(String bankAccountId);
}

class BankAccountRemoteDataSourceImpl implements BankAccountRemoteDataSource {
  final ApiClient apiClient;
  final _random = Random();

  BankAccountRemoteDataSourceImpl({required this.apiClient});

  String _newIdempotencyKey() {
    final suffix = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final rand = _random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return 'bank-$suffix-$rand';
  }

  @override
  Future<BankAccountModel> addBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountType,
    required String currency,
    required String country,
    String? alias,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/v1/users/me/bank-accounts',
      data: {
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountType': accountType,
        'currency': currency,
        'country': country,
        if (alias != null && alias.isNotEmpty) 'alias': alias,
      },
      headers: {'X-Idempotency-Key': _newIdempotencyKey()},
    );

    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty bank account response');
    }

    final parsed = ApiResponseModel.fromJson(body, BankAccountModel.fromJson);
    if (!parsed.success || parsed.data == null) {
      throw ApiException(parsed.message ?? 'Failed to add bank account');
    }

    return parsed.data!.copyWithAccountNumber(accountNumber);
  }

  @override
  Future<List<BankAccountModel>> getBankAccounts() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/v1/users/me/bank-accounts',
    );

    final body = response.data;
    if (body == null) {
      throw const ApiException('Empty bank accounts response');
    }

    final data = body['data'];
    if (data is! List<dynamic>) {
      return [];
    }

    return data
        .map((e) => BankAccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteBankAccount(String bankAccountId) async {
    final response = await apiClient.delete<Map<String, dynamic>>(
      '/api/v1/users/me/bank-accounts/$bankAccountId',
    );

    final body = response.data;
    if (body != null) {
      final success = body['success'] as bool? ?? body['status'] == 'SUCCESS';
      if (!success) {
        throw ApiException(body['message'] as String? ?? 'Failed to delete account');
      }
    }
  }
}

extension on BankAccountModel {
  BankAccountModel copyWithAccountNumber(String accountNumber) {
    return BankAccountModel(
      id: id,
      bankName: bankName,
      accountNumber: accountNumber,
      last4: accountNumber.length >= 4
          ? accountNumber.substring(accountNumber.length - 4)
          : last4,
      accountType: accountType,
      currency: currency,
      country: country,
      alias: alias,
      isPrimary: isPrimary,
    );
  }
}
