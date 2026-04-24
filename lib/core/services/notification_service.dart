/// Notification Service — FCM Push Notifications placeholder.
///
/// Will use firebase_messaging when Firebase is configured.
class NotificationService {
  NotificationService._();

  static bool _initialized = false;

  /// Initialize FCM and request permissions.
  static Future<void> initialize() async {
    // TODO: Uncomment when firebase_messaging is added
    // final messaging = FirebaseMessaging.instance;
    // await messaging.requestPermission();
    // final token = await messaging.getToken();
    // debugPrint('FCM Token: $token');
    _initialized = true;
  }

  static bool get isInitialized => _initialized;

  /// Subscribe to a topic (e.g., 'all_users', 'losari_alerts')
  static Future<void> subscribeTopic(String topic) async {
    // await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeTopic(String topic) async {
    // await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
