import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Column(
        children: [
          // Blue gradient header
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final name = data?['name'] ?? 'Warga';
              final familyRole = data?['family_role'] ?? '';
              final roleLabel = familyRole == 'KEPALA_KELUARGA'
                  ? 'Kepala Keluarga'
                  : 'Anggota Keluarga';
              final initials = name.length >= 2
                  ? name.substring(0, 2).toUpperCase()
                  : name.toUpperCase();

              return Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 20, right: 20, bottom: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.brandBlue, Color(0xFF1E3A8A)]),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2), color: Colors.white10),
                      alignment: Alignment.center,
                      child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Selamat Datang!', style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 1)),
                        const SizedBox(height: 2),
                        Text('$roleLabel - RT 03 RW 01', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w900)),
                      ]),
                    ),
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white10),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              );
            },
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Menu Grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MENU UTAMA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.slateGray, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2,
                        children: [
                          _menuItem('📄', 'Administrasi', 'Pengajuan Surat', AppColors.brandBlue, const Color(0xFFEFF6FF), onTap: () => Navigator.pushNamed(context, '/arsip-surat')),
                          _menuItem('🚨', 'Panic Button', 'Tombol Darurat', AppColors.emergencyRed, const Color(0xFFFEF2F2), isPanic: true, onTap: () => Navigator.pushNamed(context, '/sos')),
                          _menuItem('🏠', 'Data Keluarga', 'Kelola KK', AppColors.emerald, const Color(0xFFECFDF5), onTap: () => Navigator.pushNamed(context, '/keluarga')),
                          _menuItem('🕒', 'Riwayat', 'Log Kejadian', const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Dynamic Banner from Firestore (FLT-06)
                const _BannerSection(),
                // Pengajuan Terbaru
                const Text('PENGAJUAN TERBARU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.slateGray, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        alignment: Alignment.center,
                        child: const Text('📄', style: TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Surat Domisili', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.dark)),
                          Text('No. SRD-2026-001', style: TextStyle(fontSize: 9, color: AppColors.slateGray)),
                        ]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                        child: const Text('DIPROSES', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFFD97706), letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _menuItem(String emoji, String title, String subtitle, Color iconBg, Color tileBg, {bool isPanic = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: tileBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: tileBg)),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isPanic ? AppColors.emergencyRed : AppColors.dark)),
                Text(subtitle, style: const TextStyle(fontSize: 8, color: AppColors.slateGray)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// FLT-06: Dynamic Banner Section with StreamBuilder
class _BannerSection extends StatefulWidget {
  const _BannerSection();

  @override
  State<_BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<_BannerSection> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll(int count) {
    _autoScrollTimer?.cancel();
    if (count <= 1) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients) return;
      final next = ((_pageController.page?.round() ?? 0) + 1) % count;
      _pageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('banners')
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final now = DateTime.now();
        final banners = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final expiresAt = data['expires_at'] as Timestamp?;
          return expiresAt == null || expiresAt.toDate().isAfter(now);
        }).toList();

        if (banners.isEmpty) return const SizedBox.shrink();

        _startAutoScroll(banners.length);

        return Column(
          children: [
            SizedBox(
              height: 100,
              child: banners.length == 1
                  ? _BannerCard(data: banners.first.data() as Map<String, dynamic>)
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: banners.length,
                      itemBuilder: (_, i) => _BannerCard(data: banners[i].data() as Map<String, dynamic>),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final type = data['type'] as String? ?? 'INFO';
    final gradients = _gradientForType(type);
    final badge = _badgeForType(type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradients),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Text(badge, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1)),
              ),
              const SizedBox(height: 8),
              Text(data['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 4),
              Text(data['body'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Colors.white70)),
            ]),
          ),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(_emojiForType(type), style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  static List<Color> _gradientForType(String type) {
    switch (type) {
      case 'URGENT':
        return [const Color(0xFF991B1B), const Color(0xFF7F1D1D)];
      case 'EVENT':
        return [const Color(0xFF065F46), const Color(0xFF064E3B)];
      default: // INFO
        return [const Color(0xFF1E3A8A), const Color(0xFF312E81)];
    }
  }

  static String _badgeForType(String type) {
    switch (type) {
      case 'URGENT':
        return 'URGENT';
      case 'EVENT':
        return 'EVENT';
      default:
        return 'INFO RT';
    }
  }

  static String _emojiForType(String type) {
    switch (type) {
      case 'URGENT':
        return '🚨';
      case 'EVENT':
        return '🎉';
      default:
        return '📢';
    }
  }
}
