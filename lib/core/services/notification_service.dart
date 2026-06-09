import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../theme/app_colors.dart';

/// Top-level function — MUST be outside any class for FCM background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.showPanicAlert(message.data);
}

class NotificationService {
  NotificationService._();

  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null, // use default app icon
      [
        NotificationChannel(
          channelKey: 'panic_alert_channel',
          channelName: 'Panic Alert',
          channelDescription: 'Sirine darurat warga RT',
          importance: NotificationImportance.Max,
          defaultColor: AppColors.emergencyRed,
          playSound: true,
          soundSource: 'resource://raw/siren_alert',
          enableVibration: true,
          criticalAlerts: true,
          locked: true,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
        ),
      ],
    );

    // Request permissions
    await AwesomeNotifications().isNotificationAllowed().then((allowed) async {
      if (!allowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> showPanicAlert(Map<String, dynamic> data) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'panic_alert_channel',
        title: '🚨 DARURAT WARGA RT',
        body: '${data['sender_name'] ?? 'Warga'} membutuhkan bantuan segera!',
        category: NotificationCategory.Alarm,
        criticalAlert: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: false,
        locked: true,
        payload: {
          'lat': data['lat']?.toString() ?? '',
          'lng': data['lng']?.toString() ?? '',
          'panic_id': data['panic_id']?.toString() ?? '',
        },
      ),
    );
  }

  static Future<void> setupFCMListeners() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      if (message.data['type'] == 'panic_alert') {
        showPanicAlert(message.data);
      }
    });

    // Subscribe to RT topic for multicast
    await FirebaseMessaging.instance.subscribeToTopic('rt03_rw01');
  }

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
