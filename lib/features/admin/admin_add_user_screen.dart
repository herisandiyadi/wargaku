import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';

enum TipeWarga { kepalaKeluarga, anggotaKeluarga }

class AdminAddUserScreen extends StatefulWidget {
  const AdminAddUserScreen({super.key});

  @override
  State<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends State<AdminAddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();

  TipeWarga _tipeWarga = TipeWarga.kepalaKeluarga;
  String? _selectedKKId;
  XFile? _avatarFile;
  bool _submitting = false;
  String? _phoneError;

  List<QueryDocumentSnapshot> _kkList = [];

  @override
  void initState() {
    super.initState();
    _loadKKList();
  }

  Future<void> _loadKKList() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('family_role', isEqualTo: 'KEPALA_KELUARGA')
        .where('rt_id', isEqualTo: 'rt03_rw01')
        .get();
    setState(() => _kkList = snap.docs);
  }

  Future<void> _validatePhone(String phone) async {
    if (phone.length < 10) return;
    final existing = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    setState(() => _phoneError = existing.docs.isNotEmpty ? 'Nomor HP sudah terdaftar' : null);
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (picked != null) setState(() => _avatarFile = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _phoneError != null) return;
    if (_tipeWarga == TipeWarga.anggotaKeluarga && _selectedKKId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih Kepala Keluarga terlebih dahulu')));
      return;
    }

    setState(() => _submitting = true);

    try {
      // Get auth token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      await user.getIdToken(true);
      debugPrint('[AdminAddUser] Auth UID: ${user.uid}');

      // Call Cloud Function
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('createUserAccount');
      final result = await callable.call<Map<String, dynamic>>({
        'phone': _phoneCtrl.text.trim(),
        'password': _passwordCtrl.text,
        'name': _nameCtrl.text.trim(),
        'alamat': _alamatCtrl.text.trim(),
        'family_role': _tipeWarga == TipeWarga.kepalaKeluarga ? 'KEPALA_KELUARGA' : 'ANGGOTA_KELUARGA',
        'parent_kk_id': _selectedKKId,
        'rt_id': 'rt03_rw01',
      });

      final userId = result.data['uid'] as String;

      // Upload avatar if selected
      if (_avatarFile != null) {
        final ref = FirebaseStorage.instance.ref('/avatars/$userId/profile.jpg');
        await ref.putFile(File(_avatarFile!.path));
        final url = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(userId).update({'avatar_url': url});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Warga berhasil didaftarkan')));
        Navigator.pop(context);
      }
    } catch (e) {
      log("Error creating user: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAnggota = _tipeWarga == TipeWarga.anggotaKeluarga;
    final noKKAvailable = isAnggota && _kkList.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(title: const Text('Tambah Warga Baru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Avatar
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFF1F5F9),
                  backgroundImage: _avatarFile != null ? FileImage(File(_avatarFile!.path)) : null,
                  child: _avatarFile == null ? const Icon(Icons.camera_alt, color: AppColors.slateGray) : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tipe Warga
            const Text('Tipe Warga', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            SegmentedButton<TipeWarga>(
              segments: const [
                ButtonSegment(value: TipeWarga.kepalaKeluarga, label: Text('Kepala Keluarga', style: TextStyle(fontSize: 11))),
                ButtonSegment(value: TipeWarga.anggotaKeluarga, label: Text('Anggota Keluarga', style: TextStyle(fontSize: 11))),
              ],
              selected: {_tipeWarga},
              onSelectionChanged: (v) => setState(() => _tipeWarga = v.first),
            ),
            const SizedBox(height: 16),
            // KK Dropdown (only for Anggota)
            if (isAnggota) ...[
              const Text('Pilih Kepala Keluarga', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              if (noKKAvailable)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                  child: const Text('⚠️ Buat Kepala Keluarga terlebih dahulu', style: TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.w600)),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedKKId,
                  decoration: _inputDeco('Pilih KK'),
                  items: _kkList.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(value: doc.id, child: Text(data['name'] ?? data['phone'] ?? doc.id, style: const TextStyle(fontSize: 12)));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedKKId = v),
                  validator: (v) => v == null ? 'Wajib pilih KK' : null,
                ),
              const SizedBox(height: 16),
            ],
            // Name
            _field('Nama Lengkap', _nameCtrl, 'Masukkan nama'),
            const SizedBox(height: 12),
            // Phone
            const Text('Nomor HP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 12),
              decoration: _inputDeco('08xxxxxxxxxx').copyWith(errorText: _phoneError),
              onChanged: _validatePhone,
              validator: (v) => (v == null || v.length < 10) ? 'Min 10 digit' : null,
              enabled: !noKKAvailable,
            ),
            const SizedBox(height: 12),
            // Password
            _field('Password', _passwordCtrl, 'Min 6 karakter', obscure: true),
            const SizedBox(height: 12),
            // Alamat
            _field('Alamat', _alamatCtrl, 'Blok/Rumah'),
            const SizedBox(height: 24),
            // Submit
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: (_submitting || noKKAvailable) ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Daftarkan Warga', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          style: const TextStyle(fontSize: 12),
          decoration: _inputDeco(hint),
          validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : (obscure && v.length < 6 ? 'Min 6 karakter' : null),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.slateGray),
      );
}
