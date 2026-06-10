import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(title: const Text('Profil', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.brandBlue.withOpacity(0.1),
              child: Text(
                (user?.displayName ?? 'W')[0].toUpperCase(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.brandBlue),
              ),
            ),
            const SizedBox(height: 12),
            Text(user?.displayName ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(user?.email ?? user?.phoneNumber ?? '-', style: const TextStyle(fontSize: 12, color: AppColors.slateGray)),
            const SizedBox(height: 32),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, size: 18, color: Colors.red),
                label: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const Spacer(),

            // App version
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) {
                final version = snap.hasData ? 'v${snap.data!.version}+${snap.data!.buildNumber}' : '...';
                return Text('Wargaku $version', style: const TextStyle(fontSize: 11, color: AppColors.slateGray));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
