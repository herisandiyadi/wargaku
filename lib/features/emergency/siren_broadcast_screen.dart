import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SirenBroadcastScreen extends StatefulWidget {
  const SirenBroadcastScreen({super.key});

  @override
  State<SirenBroadcastScreen> createState() => _SirenBroadcastScreenState();
}

class _SirenBroadcastScreenState extends State<SirenBroadcastScreen> with TickerProviderStateMixin {
  late final List<AnimationController> _waveControllers;

  @override
  void initState() {
    super.initState();
    _waveControllers = List.generate(3, (i) {
      return AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat()
        ..value = i * 0.33;
    });
  }

  @override
  void dispose() {
    for (final c in _waveControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7F1D1D), Color(0xFF450A0A)]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Text('SEDANG DISIARKAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.emergencyRed, letterSpacing: 2)),
                ),
                const SizedBox(height: 12),
                const Text('SOS DIKIRIMKAN!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                const Spacer(),
                // Soundwave circles
                SizedBox(
                  width: 192, height: 192,
                  child: Stack(alignment: Alignment.center, children: [
                    ..._waveControllers.map((ctrl) => AnimatedBuilder(
                      animation: ctrl,
                      builder: (_, __) => Transform.scale(
                        scale: 0.95 + ctrl.value * 1.25,
                        child: Opacity(
                          opacity: 1.0 - ctrl.value,
                          child: Container(
                            width: 176, height: 176,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.emergencyRed.withOpacity(0.3)),
                          ),
                        ),
                      ),
                    )),
                    Container(
                      width: 80, height: 80,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)]),
                      alignment: Alignment.center,
                      child: const Text('⚠️', style: TextStyle(fontSize: 32)),
                    ),
                  ]),
                ),
                const Spacer(),
                // Status box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                  child: const Column(children: [
                    Text('STATUS PENGIRIMAN', style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    SizedBox(height: 4),
                    Text('SLA <3 Detik Terpenuhi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF34D399))),
                  ]),
                ),
                const SizedBox(height: 16),
                // Safe button
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('SAYA SUDAH AMAN (MATIKAN)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
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

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  const AnimatedBuilder({super.key, required Animation<double> animation, required this.builder}) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => builder(context, null);
}
