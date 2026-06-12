import '../entities/app_notification.dart';
import '../entities/transfer_limits.dart';

abstract class SettingsRepository {
  Future<List<AppNotification>> getNotifications();
  Future<TransferLimits> getLimits();
  Future<bool> getBiometricEnabled();
  Future<void> toggleBiometric(bool enabled);
}
