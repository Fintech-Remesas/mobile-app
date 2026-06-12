import '../../domain/entities/app_notification.dart';
import '../../domain/entities/transfer_limits.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<List<AppNotification>> getNotifications() {
    return localDataSource.fetchNotifications();
  }

  @override
  Future<TransferLimits> getLimits() {
    return localDataSource.fetchLimits();
  }

  @override
  Future<bool> getBiometricEnabled() {
    return localDataSource.fetchBiometricEnabled();
  }

  @override
  Future<void> toggleBiometric(bool enabled) {
    return localDataSource.saveBiometricEnabled(enabled);
  }
}
