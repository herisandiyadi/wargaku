import 'package:flutter/material.dart';
import '../../core/services/surat_service.dart';
import '../../core/theme/app_colors.dart';

class AdminSuratScreen extends StatefulWidget {
  const AdminSuratScreen({super.key});

  @override
  State<AdminSuratScreen> createState() => _AdminSuratScreenState();
}

class _AdminSuratScreenState extends State<AdminSuratScreen> {
  List<dynamic> _pengajuanList = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await SuratService.getPengajuanSurat();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        final raw = result.data;
        _pengajuanList = raw is List ? raw : (raw is Map ? (raw['data'] ?? []) : []);
      } else {
        _error = result.error;
      }
    });
  }

  Future<void> _updateStatus(
      int idPengajuan, String status, String? catatan) async {
    final result = await SuratService.updateStatusPengajuan(
      idPengajuan: idPengajuan,
      status: status,
      catatan: catatan,
    );
    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            status == 'disetujui' ? 'Pengajuan disetujui' : 'Pengajuan ditolak'),
        backgroundColor:
            status == 'disetujui' ? AppColors.emerald : AppColors.emergencyRed,
      ));
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.error ?? 'Gagal memperbarui status'),
        backgroundColor: AppColors.emergencyRed,
      ));
    }
  }

  void _showActionDialog(Map<String, dynamic> item) {
    final catatanCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item['nama_surat'] ?? 'Pengajuan',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Pemohon: ${item['nama_pemohon']}\nNIK: ${item['nik']}',
              style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Text('Keperluan: ${item['keperluan'] ?? '-'}',
              style: const TextStyle(fontSize: 11, color: AppColors.slateGray)),
          const SizedBox(height: 12),
          TextField(
            controller: catatanCtrl,
            decoration: const InputDecoration(
              hintText: 'Catatan (opsional)',
              hintStyle: TextStyle(fontSize: 12),
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(item['id_pengajuan'], 'ditolak',
                  catatanCtrl.text.trim().isEmpty ? null : catatanCtrl.text.trim());
            },
            child: const Text('Tolak',
                style: TextStyle(color: AppColors.emergencyRed)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(item['id_pengajuan'], 'disetujui',
                  catatanCtrl.text.trim().isEmpty ? null : catatanCtrl.text.trim());
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            child: const Text('Setujui',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Column(
        children: [
          Container(
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
              const Text('PERSETUJUAN SURAT',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                      letterSpacing: 1)),
            ]),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.brandBlue));
    }
    if (_error != null) {
      return Center(
          child: Text(_error!,
              style: const TextStyle(fontSize: 12, color: AppColors.slateGray)));
    }
    final pending =
        _pengajuanList.where((p) => p['status'] == 'pending').toList();
    if (pending.isEmpty) {
      return const Center(
          child: Text('Tidak ada pengajuan menunggu persetujuan',
              style: TextStyle(fontSize: 12, color: AppColors.slateGray)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pending.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final item = pending[i] as Map<String, dynamic>;
          return GestureDetector(
            onTap: () => _showActionDialog(item),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: const Text('📄', style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['nama_surat'] ?? 'Surat',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark)),
                        Text(
                            '${item['nama_pemohon']} • ${item['keperluan'] ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.slateGray)),
                      ]),
                ),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.slateGray),
              ]),
            ),
          );
        },
      ),
    );
  }
}
