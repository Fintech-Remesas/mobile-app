class RemittanceStatusMapper {
  static String label(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING_DEPOSIT':
        return 'Pendiente de depósito';
      case 'QUOTE_ACCEPTED':
        return 'Cotización aceptada';
      case 'DEPOSIT_CONFIRMED':
        return 'Depósito confirmado';
      case 'PENDING_ONRAMP_FUNDS':
        return 'Esperando fondos';
      case 'PROCESSING_ONRAMP':
        return 'Procesando depósito';
      case 'IN_BLOCKCHAIN':
      case 'IN_TRANSIT_WEB3':
        return 'En blockchain';
      case 'TX_CONFIRMED':
        return 'TX confirmada';
      case 'PAYOUT_IN_PROGRESS':
      case 'PROCESSING_OFFRAMP':
        return 'Pago en destino';
      case 'COMPLETED':
        return 'Completada';
      case 'FAILED':
      case 'FAILED_REQUIRES_REFUND':
        return 'Fallida';
      case 'REFUNDED':
        return 'Reembolsada';
      case 'CANCELLED':
        return 'Cancelada';
      default:
        return status;
    }
  }

  static bool needsDeposit(String status) {
    final upper = status.toUpperCase();
    return upper == 'PENDING_DEPOSIT' || upper == 'QUOTE_ACCEPTED';
  }
}
