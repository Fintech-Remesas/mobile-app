import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/api_config.dart';
import '../storage/token_storage.dart';
import 'remittance_status_update.dart';

typedef StatusUpdateCallback = void Function(RemittanceStatusUpdate update);

class RemittanceStatusSocketService {
  final TokenStorage tokenStorage;
  io.Socket? _socket;
  StatusUpdateCallback? _onStatusUpdate;
  String? _activeRemittanceId;

  RemittanceStatusSocketService({required this.tokenStorage});

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect({StatusUpdateCallback? onStatusUpdate}) async {
    _onStatusUpdate = onStatusUpdate;
    if (_socket?.connected == true) return;

    final userId =
        await tokenStorage.getKeycloakUserId() ?? await tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) return;

    _socket?.dispose();
    _socket = io.io(
      ApiConfig.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!
      ..onConnect((_) {
        _socket!.emit('register', {'userId': userId});
      })
      ..on('STATUS_UPDATE', (data) {
        final update = RemittanceStatusUpdate.fromSocketData(data);
        if (update.remittanceId.isEmpty) return;
        if (_activeRemittanceId != null &&
            update.remittanceId != _activeRemittanceId) {
          return;
        }
        _onStatusUpdate?.call(update);
      });
  }

  void watchRemittance(String remittanceId) {
    _activeRemittanceId = remittanceId;
  }

  void disconnect() {
    _activeRemittanceId = null;
    _onStatusUpdate = null;
    _socket?.dispose();
    _socket = null;
  }
}
