import '../../../../core/data/mock_data_source.dart';
import '../models/app_notification_model.dart';
import '../models/transfer_limits_model.dart';

abstract class SettingsLocalDataSource {
  Future<List<AppNotificationModel>> fetchNotifications();
  Future<TransferLimitsModel> fetchLimits();
  Future<bool> fetchBiometricEnabled();
  Future<void> saveBiometricEnabled(bool enabled);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final MockDataSource mockDataSource;
  bool _biometricEnabled = true;

  SettingsLocalDataSourceImpl({MockDataSource? mockDataSource})
      : mockDataSource = mockDataSource ?? MockDataSource();

  @override
  Future<List<AppNotificationModel>> fetchNotifications() async {
    await mockDataSource.simulateDelay();
    return MockDataSource.notifications
        .map(AppNotificationModel.fromJson)
        .toList();
  }

  @override
  Future<TransferLimitsModel> fetchLimits() async {
    await mockDataSource.simulateDelay();
    return TransferLimitsModel.fromJson(MockDataSource.limits);
  }

  @override
  Future<bool> fetchBiometricEnabled() async {
    await mockDataSource.simulateDelay();
    return _biometricEnabled;
  }

  @override
  Future<void> saveBiometricEnabled(bool enabled) async {
    await mockDataSource.simulateDelay();
    _biometricEnabled = enabled;
  }
}
