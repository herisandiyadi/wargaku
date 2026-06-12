import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _authorized = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final isAdmin = await AuthService.isAdmin();
    if (!isAdmin && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akses ditolak — hanya ADMIN')));
      return;
    }
    setState(() { _authorized = true; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_authorized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Admin - Daftar Warga', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.fact_check_outlined, size: 20),
            tooltip: 'Persetujuan Surat',
            onPressed: () => Navigator.pushNamed(context, '/admin/surat'),
          ),
          IconButton(
            icon: const Icon(Icons.campaign, size: 20),
            tooltip: 'Kelola Banner',
            onPressed: () => Navigator.pushNamed(context, '/admin/banners'),
          ),
          IconButton(
            icon: const Icon(Icons.person_add, size: 20),
            tooltip: 'Tambah Warga Baru',
            onPressed: () => Navigator.pushNamed(context, '/admin/add'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('rt_id', isEqualTo: 'rt03_rw01').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!.docs;

          // Group by family_id
          final Map<String, List<QueryDocumentSnapshot>> families = {};
          for (final doc in users) {
            final data = doc.data() as Map<String, dynamic>;
            final familyId = data['family_id'] as String? ?? doc.id;
            families.putIfAbsent(familyId, () => []).add(doc);
          }

          if (families.isEmpty) {
            return const Center(child: Text('Belum ada warga terdaftar', style: TextStyle(color: AppColors.slateGray)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: families.length,
            itemBuilder: (context, i) {
              final familyId = families.keys.elementAt(i);
              final members = families[familyId]!;

              // Sort: KK first
              members.sort((a, b) {
                final aRole = (a.data() as Map)['family_role'] ?? '';
                final bRole = (b.data() as Map)['family_role'] ?? '';
                return aRole == 'KEPALA_KELUARGA' ? -1 : (bRole == 'KEPALA_KELUARGA' ? 1 : 0);
              });

              return _FamilyCard(familyId: familyId, members: members);
            },
          );
        },
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  final String familyId;
  final List<QueryDocumentSnapshot> members;
  const _FamilyCard({required this.familyId, required this.members});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Keluarga #${familyId.substring(0, 6)}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.slateGray, letterSpacing: 1)),
          const SizedBox(height: 8),
          ...members.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final isKK = data['family_role'] == 'KEPALA_KELUARGA';
            return Padding(
              padding: EdgeInsets.only(left: isKK ? 0 : 24, bottom: 6),
              child: Row(children: [
                Icon(isKK ? Icons.person : Icons.person_outline, size: 16, color: isKK ? AppColors.brandBlue : AppColors.slateGray),
                const SizedBox(width: 8),
                Expanded(child: Text(data['name'] ?? data['phone'] ?? '-', style: TextStyle(fontSize: 12, fontWeight: isKK ? FontWeight.w800 : FontWeight.w500, color: AppColors.dark))),
                Text(isKK ? 'KK' : 'Anggota', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: isKK ? AppColors.brandBlue : AppColors.slateGray)),
              ]),
            );
          }),
        ],
      ),
    );
  }
}
