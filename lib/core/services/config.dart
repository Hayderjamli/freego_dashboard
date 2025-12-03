/// Simple runtime configuration holder.
/// Stores the WebSocket endpoint used by the app. This is kept in-memory
/// so the Settings page can update it at runtime without external packages.
class AppConfig {
  AppConfig._();

  /// Default WebSocket endpoint (Pi wlan0 IP)
  static String wsEndpoint = 'ws://172.20.10.3:8000';
}
