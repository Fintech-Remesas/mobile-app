class AppConstants {
  static const String baseUrl = 'http://3.151.248.130:8765';
  static const String apiPrefix = '/api/v1';

  // Auth endpoints
  static const String registerEndpoint = '$apiPrefix/users/register';
  static const String loginEndpoint = '$apiPrefix/users/login';

  // Users endpoints
  static const String meEndpoint = '$apiPrefix/users/me';
  static const String searchUsersEndpoint = '$apiPrefix/users/search';
  static const String simulateKycEndpoint = '$apiPrefix/users/me/simulate-kyc';
  static const String updateProfileEndpoint = '$apiPrefix/users/me/profile';
  static const String passwordRecoveryRequestEndpoint =
      '$apiPrefix/users/password-recovery/request';
  static const String passwordRecoveryResetEndpoint =
      '$apiPrefix/users/password-recovery/reset';

  // Cards endpoints
  static const String cardsEndpoint = '$apiPrefix/users/me/cards';

  // Bank accounts endpoints
  static const String bankAccountsEndpoint = '$apiPrefix/users/me/bank-accounts';

  // Ledger / Balance endpoints
  static String accountCalculatedBalanceEndpoint(String userId) =>
      '$apiPrefix/accounts/user/$userId/calculated-balance';

  // Ledger / Movements endpoints
  static String userMovementsEndpoint(String userId) =>
      '$apiPrefix/movements/user/$userId';
}
