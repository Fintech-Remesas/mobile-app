import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  /// Override at runtime for physical devices, e.g.:
  /// `ApiConfig.overrideBaseUrl = 'http://192.168.1.10:8765';`
  static String? overrideBaseUrl;

  static String get baseUrl {
    if (overrideBaseUrl != null && overrideBaseUrl!.isNotEmpty) {
      return overrideBaseUrl!;
    }

    if (kIsWeb) return 'http://localhost:8765';

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8765';
    }

    return 'http://localhost:8765';
  }
}
