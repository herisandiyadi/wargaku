import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/admin_add_user_screen.dart';
import 'features/admin/admin_banner_screen.dart';
import 'features/admin/admin_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/emergency/alarm_received_screen.dart';
import 'features/emergency/siren_broadcast_screen.dart';
import 'features/emergency/sos_countdown_screen.dart';
import 'features/navigation/main_shell.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Activate App Check (debug for development, playIntegrity for release)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // Register background handler FIRST (FLT-02 requirement)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Awesome Notifications
  await NotificationService.init();

  // Check if user already logged in
  String initialRoute = '/login';
  if (FirebaseAuth.instance.currentUser != null) {
    final isAdmin = await AuthService.isAdmin();
    initialRoute = isAdmin ? '/admin' : '/home';
  }

  runApp(WargakuApp(initialRoute: initialRoute));
}

class WargakuApp extends StatefulWidget {
  final String initialRoute;
  const WargakuApp({super.key, required this.initialRoute});

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
      initialRoute: widget.initialRoute,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const MainShell(),
        '/sos': (_) => const SosCountdownScreen(),
        '/siren': (_) => const SirenBroadcastScreen(),
        '/alarm': (_) => const AlarmReceivedScreen(),
        '/admin': (_) => const AdminScreen(),
        '/admin/add': (_) => const AdminAddUserScreen(),
        '/admin/banners': (_) => const AdminBannerScreen(),
      },
    );
  }
}
