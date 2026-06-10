import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AdminBannerScreen extends StatelessWidget {
  const AdminBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Kelola Banner', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('banners').orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Belum ada banner', style: TextStyle(color: AppColors.slateGray)));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final isActive = data['is_active'] as bool? ?? false;
              final type = data['type'] as String? ?? 'INFO';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isActive ? AppColors.emerald.withOpacity(0.3) : const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          _typeBadge(type),
                          const SizedBox(width: 8),
                          if (!isActive) const Text('NONAKTIF', style: TextStyle(fontSize: 8, color: AppColors.slateGray, fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 6),
                        Text(data['title'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.dark)),
                        Text(data['body'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: AppColors.slateGray)),
                      ]),
                    ),
                    Switch(
                      value: isActive,
                      onChanged: (val) => doc.reference.update({'is_active': val}),
                    ),
                    PopupMenuButton<String>(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      ],
                      onSelected: (action) {
                        if (action == 'edit') _openForm(context, doc: doc);
                        if (action == 'delete') _confirmDelete(context, doc.reference);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  static Widget _typeBadge(String type) {
    final color = type == 'URGENT' ? AppColors.emergencyRed : type == 'EVENT' ? AppColors.emerald : AppColors.brandBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(type, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: color)),
    );
  }

  static void _confirmDelete(BuildContext context, DocumentReference ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Banner?'),
        content: const Text('Banner akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () { ref.delete(); Navigator.pop(context); },
            child: const Text('Hapus', style: TextStyle(color: AppColors.emergencyRed)),
          ),
        ],
      ),
    );
  }

  static void _openForm(BuildContext context, {DocumentSnapshot? doc}) {
    final data = doc?.data() as Map<String, dynamic>?;
    final titleCtrl = TextEditingController(text: data?['title'] ?? '');
    final bodyCtrl = TextEditingController(text: data?['body'] ?? '');
    String type = data?['type'] ?? 'INFO';
    bool isActive = data?['is_active'] ?? true;
    DateTime? expiresAt = (data?['expires_at'] as Timestamp?)?.toDate();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(doc == null ? 'Tambah Banner' : 'Edit Banner', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.length < 5) ? 'Min 5 karakter' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: bodyCtrl,
                decoration: const InputDecoration(labelText: 'Isi Banner', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => (v == null || v.length < 10) ? 'Min 10 karakter' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Tipe', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'INFO', child: Text('INFO')),
                  DropdownMenuItem(value: 'URGENT', child: Text('URGENT')),
                  DropdownMenuItem(value: 'EVENT', child: Text('EVENT')),
                ],
                onChanged: (v) => setSheetState(() => type = v!),
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Aktif'),
                Switch(value: isActive, onChanged: (v) => setSheetState(() => isActive = v)),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(expiresAt != null ? '${expiresAt!.day}/${expiresAt!.month}/${expiresAt!.year}' : 'Set Expiry'),
                  onPressed: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: expiresAt ?? DateTime.now().add(const Duration(days: 7)), firstDate: DateTime.now(), lastDate: DateTime(2030));
                    if (picked != null) setSheetState(() => expiresAt = picked);
                  },
                ),
                if (expiresAt != null) IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setSheetState(() => expiresAt = null)),
              ]),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final payload = {
                    'title': titleCtrl.text.trim(),
                    'body': bodyCtrl.text.trim(),
                    'type': type,
                    'is_active': isActive,
                    'expires_at': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
                  };
                  if (doc == null) {
                    payload['created_at'] = FieldValue.serverTimestamp();
                    payload['created_by'] = FirebaseAuth.instance.currentUser!.uid;
                    FirebaseFirestore.instance.collection('banners').add(payload);
                  } else {
                    doc.reference.update(payload);
                  }
                  Navigator.pop(ctx);
                },
                child: Text(doc == null ? 'Simpan' : 'Update'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
