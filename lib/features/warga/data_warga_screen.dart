import 'package:flutter/material.dart';
import '../../core/services/surat_service.dart';
import '../../core/theme/app_colors.dart';

class DataWargaScreen extends StatefulWidget {
  const DataWargaScreen({super.key});

  @override
  State<DataWargaScreen> createState() => _DataWargaScreenState();
}

class _DataWargaScreenState extends State<DataWargaScreen> {
  List<dynamic> _wargaList = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWarga();
  }

  Future<void> _loadWarga() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await SuratService.getWarga();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        final raw = result.data;
        _wargaList =
            raw is List ? raw : (raw is Map ? (raw['data'] ?? []) : []);
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
        const Icon(Icons.people_outline, size: 20, color: AppColors.brandBlue),
        const SizedBox(width: 8),
        const Text('DATA WARGA',
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
            TextButton(onPressed: _loadWarga, child: const Text('Coba Lagi')),
          ]),
        ),
      );
    }
    if (_wargaList.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('👥', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text('Data warga belum tersedia',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateGray)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadWarga,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _wargaList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _WargaCard(data: _wargaList[i]),
      ),
    );
  }
}

class _WargaCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _WargaCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: const Icon(Icons.person, size: 18, color: AppColors.slateGray),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['nama'] ?? '-',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark)),
            const SizedBox(height: 2),
            Text('NIK: ${data['nik'] ?? '-'}',
                style: const TextStyle(fontSize: 9, color: AppColors.slateGray)),
            Text(
                '${data['hubungan_keluarga'] ?? data['family_role'] ?? '-'} • ${data['jenis_kelamin'] ?? '-'}',
                style: const TextStyle(fontSize: 9, color: AppColors.slateGray)),
          ]),
        ),
      ]),
    );
  }
}
