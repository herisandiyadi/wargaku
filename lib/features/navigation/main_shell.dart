import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../home/dashboard_screen.dart';
import '../log/log_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _pages = const [
    DashboardScreen(),
    Scaffold(body: Center(child: Text('Surat'))),
    SizedBox(), // placeholder for FAB
    LogScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.white,
        elevation: 12,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home, 'Home'),
              _navItem(1, Icons.description_outlined, 'Surat'),
              const SizedBox(width: 48), // gap for FAB
              _navItem(3, Icons.list_alt, 'Kejadian'),
              _navItem(4, Icons.person_outline, 'Profil'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/sos'),
        backgroundColor: AppColors.emergencyRed,
        elevation: 6,
        child: const Text('🚨', style: TextStyle(fontSize: 22)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final active = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: active ? AppColors.brandBlue : AppColors.slateGray),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? AppColors.brandBlue : AppColors.slateGray)),
        ],
      ),
    );
  }
}
