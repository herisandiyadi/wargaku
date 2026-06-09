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
          Container(
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
                  child: const Text('KK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Selamat Datang!', style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 1)),
                    SizedBox(height: 2),
                    Text('Kepala Keluarga - RT 03 RW 01', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w900)),
                  ]),
                ),
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white10),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
                ),
              ],
            ),
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
                          _menuItem('📄', 'Administrasi', 'Pengajuan Surat', AppColors.brandBlue, const Color(0xFFEFF6FF)),
                          _menuItem('🚨', 'Panic Button', 'Tombol Darurat', AppColors.emergencyRed, const Color(0xFFFEF2F2), isPanic: true),
                          _menuItem('🏠', 'Data Keluarga', 'Kelola KK', AppColors.emerald, const Color(0xFFECFDF5)),
                          _menuItem('🕒', 'Riwayat', 'Log Kejadian', const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Info RT banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF312E81)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                            child: const Text('INFO RT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF93C5FD), letterSpacing: 1)),
                          ),
                          const SizedBox(height: 8),
                          const Text('Kerja Bakti Fogging RT 03', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                          const SizedBox(height: 4),
                          const Text('Minggu depan jam 07:00 WIB di lapangan.', style: TextStyle(fontSize: 9, color: Color(0xFFBFDBFE))),
                        ]),
                      ),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: const Text('📢', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 80), // space for bottom nav
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _menuItem(String emoji, String title, String subtitle, Color iconBg, Color tileBg, {bool isPanic = false}) {
    return Container(
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
    );
  }
}
