import 'package:flutter/material.dart';
import '../../core/services/surat_service.dart';
import '../../core/theme/app_colors.dart';

class PengajuanSuratScreen extends StatefulWidget {
  const PengajuanSuratScreen({super.key});

  @override
  State<PengajuanSuratScreen> createState() => _PengajuanSuratScreenState();
}

class _PengajuanSuratScreenState extends State<PengajuanSuratScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _keperluanCtrl = TextEditingController();

  List<dynamic> _jenisSurat = [];
  int? _selectedSuratId;
  bool _loadingJenis = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadJenisSurat();
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _keperluanCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadJenisSurat() async {
    final result = await SuratService.getJenisSurat();
    if (!mounted) return;
    setState(() {
      _loadingJenis = false;
      if (result.success) {
        final raw = result.data;
        _jenisSurat = raw is List ? raw : (raw is Map ? (raw['data'] ?? []) : []);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedSuratId == null) return;

    setState(() => _submitting = true);
    final result = await SuratService.createPengajuan(
      idSurat: _selectedSuratId!,
      namaPemohon: _namaCtrl.text.trim(),
      nik: _nikCtrl.text.trim(),
      keperluan: _keperluanCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pengajuan surat berhasil dikirim'),
        backgroundColor: AppColors.emerald,
      ));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.error ?? 'Gagal mengirim pengajuan'),
        backgroundColor: AppColors.emergencyRed,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loadingJenis
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.brandBlue))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildForm(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          bottom: 12),
      color: Colors.white,
      child: Row(children: [
        GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 20)),
        const SizedBox(width: 16),
        const Text('PENGAJUAN SURAT BARU',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.dark,
                letterSpacing: 1)),
      ]),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Jenis Surat dropdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('JENIS SURAT',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slateGray,
                        letterSpacing: 1.5)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedSuratId,
                  decoration: _inputDecoration('Pilih jenis surat'),
                  items: _jenisSurat.map<DropdownMenuItem<int>>((s) {
                    final id = s['id_surat'] is int
                        ? s['id_surat'] as int
                        : int.tryParse(s['id_surat'].toString()) ?? 0;
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(s['nama_surat'] ?? '',
                          style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedSuratId = v),
                  validator: (v) =>
                      v == null ? 'Pilih jenis surat' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Data Pemohon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DATA PEMOHON',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slateGray,
                        letterSpacing: 1.5)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _namaCtrl,
                  decoration: _inputDecoration('Nama Lengkap Pemohon'),
                  style: const TextStyle(fontSize: 12),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nikCtrl,
                  decoration: _inputDecoration('NIK (16 digit)'),
                  style: const TextStyle(fontSize: 12),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                    if (v.trim().length != 16) return 'NIK harus 16 digit';
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Keperluan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('KEPERLUAN',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slateGray,
                        letterSpacing: 1.5)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _keperluanCtrl,
                  decoration:
                      _inputDecoration('Jelaskan keperluan pengajuan surat'),
                  style: const TextStyle(fontSize: 12),
                  maxLines: 4,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Submit button
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Kirim Pengajuan',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.slateGray),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.brandBlue)),
      counterText: '',
    );
  }
}
