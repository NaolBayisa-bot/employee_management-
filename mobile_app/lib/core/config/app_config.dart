/// Application-wide configuration constants.
class AppConfig {
  /// Base URL for the backend REST API.
  ///
  /// - Android emulator attaches to the host machine via 10.0.2.2.
  /// - A real Android phone must use the computer's local IP on the same
  ///   Wi-Fi network, e.g. http://192.168.1.20:3000.
  /// - iOS simulator can use http://localhost:3000.
  static const String apiBaseUrl = 'http://10.0.2.2:3000';
}
