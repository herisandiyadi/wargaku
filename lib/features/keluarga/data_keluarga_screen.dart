import 'package:flutter/material.dart';
import '../../core/services/surat_service.dart';
import '../../core/theme/app_colors.dart';

class DataKeluargaScreen extends StatefulWidget {
  const DataKeluargaScreen({super.key});

  @override
  State<DataKeluargaScreen> createState() => _DataKeluargaScreenState();
}

class _DataKeluargaScreenState extends State<DataKeluargaScreen> {
  Map<String, dynamic>? _kkData;
  List<dynamic> _anggotaList = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final kkResult = await SuratService.getKartuKeluarga();
    final wargaResult = await SuratService.getWarga();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (kkResult.success) {
        final raw = kkResult.data;
        if (raw is Map) {
          _kkData = Map<String, dynamic>.from(raw['data'] ?? raw);
        } else if (raw is List && raw.isNotEmpty) {
          _kkData = Map<String, dynamic>.from(raw.first);
        }
      } else {
        _error = kkResult.error;
        return;
      }
      if (wargaResult.success) {
        final raw = wargaResult.data;
        _anggotaList =
            raw is List ? raw : (raw is Map ? (raw['data'] ?? []) : []);
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
          child:
              const Icon(Icons.arrow_back, size: 20, color: AppColors.dark),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.home_outlined, size: 20, color: AppColors.brandBlue),
        const SizedBox(width: 8),
        const Text('DATA KELUARGA',
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
            TextButton(onPressed: _loadData, child: const Text('Coba Lagi')),
          ]),
        ),
      );
    }
    if (_kkData == null) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🏠', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text('Data Kartu Keluarga belum tersedia',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateGray)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildKKCard(),
          const SizedBox(height: 16),
          const Text('ANGGOTA KELUARGA',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateGray,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          ..._anggotaList.map((w) => _buildAnggotaCard(w)),
        ],
      ),
    );
  }

  Widget _buildKKCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: const Text('🏠', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          const Text('KARTU KELUARGA',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark,
                  letterSpacing: 1)),
        ]),
        const SizedBox(height: 14),
        _infoRow('No. KK', _kkData?['no_kk'] ?? '-'),
        _infoRow('Kepala Keluarga', _kkData?['kepala_keluarga'] ?? '-'),
        _infoRow('Alamat', _kkData?['alamat'] ?? '-'),
        _infoRow('RT/RW', '${_kkData?['rt'] ?? '-'} / ${_kkData?['rw'] ?? '-'}'),
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.slateGray,
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.dark,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _buildAnggotaCard(dynamic warga) {
    final data = warga is Map<String, dynamic> ? warga : <String, dynamic>{};
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: const Icon(Icons.person, size: 16, color: AppColors.slateGray),
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
            Text(
                'NIK: ${data['nik'] ?? '-'} • ${data['hubungan_keluarga'] ?? data['family_role'] ?? '-'}',
                style: const TextStyle(fontSize: 9, color: AppColors.slateGray)),
          ]),
        ),
      ]),
    );
  }
}
