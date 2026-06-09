import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/panic_service.dart';
import '../../core/theme/app_colors.dart';

class SosCountdownScreen extends StatefulWidget {
  const SosCountdownScreen({super.key});

  @override
  State<SosCountdownScreen> createState() => _SosCountdownScreenState();
}

class _SosCountdownScreenState extends State<SosCountdownScreen> with SingleTickerProviderStateMixin {
  int _seconds = 3;
  Timer? _timer;
  late AnimationController _spinController;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
        _triggerPanic();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _triggerPanic() async {
    setState(() => _sending = true);
    try {
      await PanicService.sendPanicAlert();
      if (mounted) Navigator.pushReplacementNamed(context, '/siren');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim: $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF450A0A), Color(0xFF0F172A)]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.emergencyRed.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20)),
                  child: const Text('MENGHUBUNGI WARGA RT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFFECACA), letterSpacing: 2)),
                ),
                const SizedBox(height: 12),
                Text(
                  _sending ? 'MENGIRIM SINYAL...' : 'SIAGA DARURAT AKAN TERSIAR',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const Spacer(),
                // Countdown ring
                SizedBox(
                  width: 176, height: 176,
                  child: Stack(alignment: Alignment.center, children: [
                    Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF7F1D1D).withValues(alpha: 0.4), width: 4))),
                    RotationTransition(
                      turns: _spinController,
                      child: Container(
                        width: 176, height: 176,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(colors: [AppColors.emergencyRed, Colors.transparent, Colors.transparent]),
                        ),
                      ),
                    ),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      _sending
                          ? const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: Colors.white))
                          : Text('$_seconds', style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(_sending ? 'MENGIRIM' : 'DETIK', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFCA5A5), letterSpacing: 2)),
                    ]),
                  ]),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF7F1D1D).withValues(alpha: 0.4), borderRadius: BorderRadius.circular(16)),
                  child: const Text(
                    '💡 Suara sirine keras akan otomatis berbunyi di handphone tetangga dalam jangkauan RT jika waktu habis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Color(0xFFFECACA), fontWeight: FontWeight.w600, height: 1.5),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton(
                    onPressed: _sending ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.white10),
                    child: const Text('BATALKAN PENGIRIMAN (BATAL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
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
