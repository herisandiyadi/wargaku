import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/admin_add_user_screen.dart';
import 'features/admin/admin_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/emergency/alarm_received_screen.dart';
import 'features/emergency/siren_broadcast_screen.dart';
import 'features/emergency/sos_countdown_screen.dart';
import 'features/navigation/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Register background handler FIRST (FLT-02 requirement)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Awesome Notifications
  await NotificationService.init();

  runApp(const WargakuApp());
}

class WargakuApp extends StatefulWidget {
  const WargakuApp({super.key});

  @override
  State<WargakuApp> createState() => _WargakuAppState();
}

class _WargakuAppState extends State<WargakuApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.setupFCMListeners();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wargaku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const MainShell(),
        '/sos': (_) => const SosCountdownScreen(),
        '/siren': (_) => const SirenBroadcastScreen(),
        '/alarm': (_) => const AlarmReceivedScreen(),
        '/admin': (_) => const AdminScreen(),
        '/admin/add': (_) => const AdminAddUserScreen(),
      },
    );
  }
}
// Buka app, login dengan email admin@wargajatiasih.com dan password Admin@Jatiasih2024