import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BatteryPermissionSheet extends StatelessWidget {
  const BatteryPermissionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BatteryPermissionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: const Text('⚡', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Aktifkan Proteksi Latar Belakang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.dark)),
                Text('INSTRUKSI HAK AKSES KHUSUS ANDROID', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.slateGray, letterSpacing: 0.5)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          const Text(
            'Agar handphone Anda tetap menerima bunyi sirine siaga darurat meskipun aplikasi ditutup penuh (Killed State):',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.slateGray, height: 1.5),
          ),
          const SizedBox(height: 16),
          _step('1', 'Setel manajemen daya baterai Wargaku ke status "Tidak Dibatasi / Unrestricted".'),
          const SizedBox(height: 10),
          _step('2', 'Izinkan notifikasi mengambil alih sistem suara untuk membunyikan sirine lokal.'),
          const SizedBox(height: 24),
          // CTA
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Atur Ke "Unrestricted" Sekarang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity, height: 40,
            child: TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nanti Saja', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slateGray)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(String num, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 20, height: 20,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.brandBlue),
          alignment: Alignment.center,
          child: Text(num, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.slateGray, height: 1.4))),
      ]),
    );
  }
}
