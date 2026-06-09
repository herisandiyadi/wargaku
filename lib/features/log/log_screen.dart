import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  Future<void> _openMaps() async {
    final uri = Uri.parse('google.navigation:q=-6.229728,106.818306');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
            color: Colors.white,
            child: Row(children: [
              GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, size: 20)),
              const SizedBox(width: 16),
              const Text('LOG KEJADIAN DARURAT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.dark, letterSpacing: 1)),
            ]),
          ),
          // Log list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Active crisis card
                _ActiveCrisisCard(onOpenMaps: _openMaps),
                const SizedBox(height: 16),
                // Resolved card
                const _ResolvedCrisisCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveCrisisCard extends StatelessWidget {
  final VoidCallback onOpenMaps;
  const _ActiveCrisisCard({required this.onOpenMaps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECACA))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.emergencyRed)),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Budi Santoso', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.dark)),
              Text('Rumah B-12 • RT 03 RW 01', style: TextStyle(fontSize: 9, color: Color(0xFFB91C1C), fontWeight: FontWeight.w600)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.emergencyRed, borderRadius: BorderRadius.circular(12)),
            child: const Text('AKTIF', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
          ),
        ]),
        const SizedBox(height: 12),
        const Text(
          'Pemicuan aktif pukul 09:25:00 WIB. Koordinat terdeteksi di lokasi presisi.',
          style: TextStyle(fontSize: 11, color: AppColors.slateGray, height: 1.5),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onOpenMaps,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.emergencyRed, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: const Text('🗺️  Buka Rute Google Maps', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
          ),
        ),
      ]),
    );
  }
}

class _ResolvedCrisisCard extends StatelessWidget {
  const _ResolvedCrisisCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFCBD5E1))),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Yudi Hermawan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slateGray)),
              SizedBox(height: 2),
              Text('Rumah A-04 • RT 03 RW 01', style: TextStyle(fontSize: 9, color: AppColors.slateGray)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: const Text('SELESAI', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.slateGray)),
          ),
        ]),
        const SizedBox(height: 12),
        const Text(
          'Keadaan darurat diatasi oleh Tim Keamanan warga pukul 08:12:00 WIB.',
          style: TextStyle(fontSize: 11, color: AppColors.slateGray, height: 1.5),
        ),
      ]),
    );
  }
}
