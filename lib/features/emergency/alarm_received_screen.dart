import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class AlarmReceivedScreen extends StatelessWidget {
  const AlarmReceivedScreen({super.key});

  Future<void> _openMaps() async {
    final uri = Uri.parse('google.navigation:q=-6.229728,106.818306');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColors.emergencyRed,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Emergency badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Text('🚨 EMERGENCY WARGA RT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.emergencyRed, letterSpacing: 2)),
                ),
                const SizedBox(height: 12),
                const Text('SIAGA DARURAT AKTIF', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const Spacer(),
                // Neighbor crisis card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                  child: Column(children: [
                    Row(children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
                        alignment: Alignment.center,
                        child: const Text('BS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Budi Santoso', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                        SizedBox(height: 2),
                        Text('Warga RT 03 - Blok B-12', style: TextStyle(fontSize: 10, color: Color(0xFFFECACA))),
                      ]),
                    ]),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF450A0A).withOpacity(0.4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF7F1D1D).withOpacity(0.4))),
                      child: const Text(
                        '⚠️ "Tolong ada pencurian masuk pekarangan!"',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFFFECACA), fontWeight: FontWeight.w600, height: 1.4),
                      ),
                    ),
                  ]),
                ),
                const Spacer(),
                // Action buttons
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _openMaps,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4),
                    child: const Text('🗺️  Navigasi Google Maps (FLT-04)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.emergencyRed, letterSpacing: 0.5)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white10),
                      backgroundColor: const Color(0xFF7F1D1D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('HENTIKAN BUNYI SIRINE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
