class AppConstants {
  // Si usas un dispositivo físico o tu propio celular por Wi-Fi, usa tu IP local.
  // 10.0.2.2 es SOLO para el emulador de Android.
  // PRODUCCIÓN:
  static const String baseUrl = 'http://3.151.248.130:8765';
  static const String web3SocketUrl = 'http://3.151.248.130:3001';

  // LOCAL (Emulador):
  // static const String baseUrl = 'http://10.0.2.2:8765';
  // static const String web3SocketUrl = 'ws://10.0.2.2:8765'; // api-gateway websocket proxy
  static const String apiPrefix = '/api/v1';
  static const String registerEndpoint = '$apiPrefix/users/register';
  static const String loginEndpoint = '$apiPrefix/users/login';

  // Users endpoints
  static const String meEndpoint = '$apiPrefix/users/me';
  static const String searchUsersEndpoint = '$apiPrefix/users/search';
  static const String simulateKycEndpoint = '$apiPrefix/users/me/simulate-kyc';
  static const String claimWelcomeBonusEndpoint = '$apiPrefix/users/me/claim-welcome-bonus';
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
      '$apiPrefix/accounts/user/$userId/balance';

  // Ledger / Movements endpoints
  static String userMovementsEndpoint(String userId) =>
      '$apiPrefix/movements/user/$userId';

  // Transfer / Web3 Endpoints
  static const String quotesEndpoint = '$apiPrefix/quotes';
  static const String remittancesEndpoint = '$apiPrefix/remittances';
  static String confirmDepositEndpoint(String remittanceId) => 
      '$apiPrefix/remittances/$remittanceId/confirm-deposit';
  static String orderTimelineEndpoint(String remittanceId) => 
      '$apiPrefix/remittances/$remittanceId';
  static String trackTxEndpoint(String txHash) => 
      '$apiPrefix/tx/$txHash/track';
  static String statusTxEndpoint(String txHash) => 
      '$apiPrefix/tx/$txHash/status';
  static const String walletInfoEndpoint = '$apiPrefix/tx/wallet/info';

  // Metrics endpoints (Tesis)
  static const String traceabilityMetricsEndpoint = '$apiPrefix/metrics/traceability';
  static const String traceabilityExportEndpoint = '$apiPrefix/metrics/traceability/export';
  static String unitaryMetricsEndpoint(String remittanceId) =>
      '$apiPrefix/metrics/remittance/$remittanceId';

  // RPC público para verificación independiente (sin pasar por backend Sagiro)
  static const String polygonAmoyRpcUrl = 'https://rpc-amoy.polygon.technology';
  static const String registryContractAddress = '0xdDBD7864d62434d1855a98F743e24A4bBB134E4E'; // actualizar al desplegar
  static const String polygonscanBaseUrl = 'https://amoy.polygonscan.com';
}
