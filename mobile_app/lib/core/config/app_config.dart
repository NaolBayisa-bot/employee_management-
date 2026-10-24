class AppConfig {
  /// Android emulator uses 10.0.2.2 to reach the host machine's localhost.
  /// A real phone must use the computer's local IP, e.g. http://192.168.1.20:3000
  /// on the same Wi-Fi network.
  /// iOS simulator can use http://localhost:3000.
  static const String apiBaseUrl = 'http://192.168.137.69:3000';
}
