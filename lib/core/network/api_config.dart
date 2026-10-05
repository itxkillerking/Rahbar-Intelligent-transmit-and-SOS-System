import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kDebugMode) {
      // Using 127.0.0.1 for android adb reverse over TCP
      // adb reverse tcp:8000 tcp:8000
      return 'http://127.0.0.1:8000/api/v1';
    }
    return 'https://api.rahbar.example.com/api/v1';
  }
}
