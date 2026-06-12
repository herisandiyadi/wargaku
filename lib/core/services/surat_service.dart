import 'api_service.dart';

class SuratService {
  SuratService._();

  /// Get list of available surat types
  static Future<ApiResult> getJenisSurat() => ApiService.get('apiSurat');

  /// Get pengajuan history (filtered by role on backend)
  static Future<ApiResult> getPengajuanSurat() =>
      ApiService.get('apiPengajuanSurat');

  /// Submit new pengajuan surat (kepala_keluarga or admin only)
  static Future<ApiResult> createPengajuan({
    required int idSurat,
    required String namaPemohon,
    required String nik,
    required String keperluan,
  }) =>
      ApiService.post('apiPengajuanSurat', {
        'id_surat': idSurat,
        'nama_pemohon': namaPemohon,
        'nik': nik,
        'keperluan': keperluan,
      });

  /// Admin: approve or reject pengajuan
  static Future<ApiResult> updateStatusPengajuan({
    required int idPengajuan,
    required String status,
    String? catatan,
  }) =>
      ApiService.patch('apiPengajuanSurat', {
        'id_pengajuan': idPengajuan,
        'status': status,
        if (catatan != null) 'catatan': catatan,
      });

  /// Get arsip surat
  static Future<ApiResult> getArsipSurat() => ApiService.get('apiArsipSurat');

  /// Get kartu keluarga data
  static Future<ApiResult> getKartuKeluarga() =>
      ApiService.get('apiKartuKeluarga');

  /// Get warga/family members data
  static Future<ApiResult> getWarga() => ApiService.get('apiWarga');
}
