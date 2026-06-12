import 'package:flutter/material.dart';
import '../../core/services/surat_service.dart';
import '../../core/theme/app_colors.dart';
import 'pengajuan_surat_screen.dart';

class SuratScreen extends StatefulWidget {
  const SuratScreen({super.key});

  @override
  State<SuratScreen> createState() => _SuratScreenState();
}

class _SuratScreenState extends State<SuratScreen> {
  List<dynamic> _pengajuanList = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPengajuan();
  }

  Future<void> _loadPengajuan() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final submitted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const PengajuanSuratScreen()),
          );
          if (submitted == true) _loadPengajuan();
        },
        backgroundColor: AppColors.brandBlue,
        icon: const Icon(Icons.add, color: Colors.white, size: 18),
        label: const Text('Ajukan Surat',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
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
      child: const Row(children: [
        Icon(Icons.description_outlined, size: 20, color: AppColors.brandBlue),
        SizedBox(width: 12),
        Text('PENGAJUAN SURAT',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.dark,
                letterSpacing: 1)),
      ]),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.brandBlue));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.slateGray),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.slateGray)),
            const SizedBox(height: 16),
            TextButton(
                onPressed: _loadPengajuan, child: const Text('Coba Lagi')),
          ]),
        ),
      );
    }
    if (_pengajuanList.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('📄', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text('Belum ada pengajuan surat',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateGray)),
          SizedBox(height: 4),
          Text('Tekan tombol + untuk mengajukan surat baru',
              style: TextStyle(fontSize: 10, color: AppColors.slateGray)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPengajuan,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _pengajuanList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _PengajuanCard(data: _pengajuanList[i]),
      ),
    );
  }
}

class _PengajuanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PengajuanCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';
    final statusColor = _statusColor(status);
    final statusBg = _statusBg(status);
    final statusLabel = status.toString().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: const Text('📄', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['nama_surat'] ?? 'Surat',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark)),
                    Text('Pemohon: ${data['nama_pemohon'] ?? '-'}',
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.slateGray)),
                  ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: statusBg, borderRadius: BorderRadius.circular(12)),
              child: Text(statusLabel,
                  style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.5)),
            ),
          ]),
          if (data['keperluan'] != null) ...[
            const SizedBox(height: 8),
            Text('Keperluan: ${data['keperluan']}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.slateGray,
                    height: 1.4)),
          ],
          if (data['catatan'] != null && data['catatan'].isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Catatan: ${data['catatan']}',
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.amber,
                    fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'disetujui':
        return AppColors.emerald;
      case 'ditolak':
        return AppColors.emergencyRed;
      default:
        return const Color(0xFFD97706);
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'disetujui':
        return const Color(0xFFECFDF5);
      case 'ditolak':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFFEF3C7);
    }
  }
}
