import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/surat_service.dart';
import '../../core/theme/app_colors.dart';

class ArsipSuratScreen extends StatefulWidget {
  const ArsipSuratScreen({super.key});

  @override
  State<ArsipSuratScreen> createState() => _ArsipSuratScreenState();
}

class _ArsipSuratScreenState extends State<ArsipSuratScreen> {
  List<dynamic> _arsipList = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArsip();
  }

  Future<void> _loadArsip() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await SuratService.getArsipSurat();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        final raw = result.data;
        _arsipList =
            raw is List ? raw : (raw is Map ? (raw['data'] ?? []) : []);
      } else {
        _error = result.error;
      }
    });
  }

  Future<void> _downloadPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka file')),
      );
    }
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
        InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, size: 20, color: AppColors.dark),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.archive_outlined, size: 20, color: AppColors.brandBlue),
        const SizedBox(width: 8),
        const Text('ARSIP SURAT',
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
            TextButton(onPressed: _loadArsip, child: const Text('Coba Lagi')),
          ]),
        ),
      );
    }
    if (_arsipList.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('📁', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text('Belum ada arsip surat',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateGray)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadArsip,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _arsipList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final item = _arsipList[i] is Map<String, dynamic>
              ? _arsipList[i] as Map<String, dynamic>
              : <String, dynamic>{};
          return _ArsipCard(data: item, onDownload: _downloadPdf);
        },
      ),
    );
  }
}

class _ArsipCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Future<void> Function(String url) onDownload;
  const _ArsipCard({required this.data, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final fileUrl = data['file_url'] ?? data['url'] ?? '';

    return Container(
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['nama_surat'] ?? data['judul'] ?? 'Surat',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark)),
            Text(data['tanggal'] ?? data['created_at'] ?? '-',
                style: const TextStyle(fontSize: 9, color: AppColors.slateGray)),
          ]),
        ),
        if (fileUrl.toString().isNotEmpty)
          InkWell(
            onTap: () => onDownload(fileUrl),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.download, size: 16, color: AppColors.brandBlue),
            ),
          ),
      ]),
    );
  }
}
