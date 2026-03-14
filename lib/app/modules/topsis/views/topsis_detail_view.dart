import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../models/analisis_topsis_model.dart';
import '../../../services/pdf_service.dart';
import '../controllers/topsis_controller.dart';
import '../../../core/core.dart';

class TopsisDetailView extends GetView<TopsisController> {
  final AnalisisTopsisModel analysis = Get.arguments as AnalisisTopsisModel;

  TopsisDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Sort results by preference value descending
    final sortedResults = List<Map<String, dynamic>>.from(analysis.results);
    sortedResults.sort(
      (a, b) => ((b['nilai_preferensi'] as num?)?.toDouble() ?? 0.0).compareTo(
        (a['nilai_preferensi'] as num?)?.toDouble() ?? 0.0,
      ),
    );
    final top3 = sortedResults.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.hondaRed,
        title: const Text(
          'Detail Analisis TOPSIS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analysis Information Card
            _buildAnalysisInfoCard(context),
            const SizedBox(height: 24),

            // Top Rank Items Panel
            _buildTopRankItemsPanel(context, top3),
            const SizedBox(height: 24),

            // Criteria Used Section
            _buildCriteriaSection(),
            const SizedBox(height: 24),

            // Ranking Result Table
            _buildRankingTable(sortedResults),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisInfoCard(BuildContext context) {
    final dateFormat = DateTime(
      analysis.createdAt.toDate().year,
      analysis.createdAt.toDate().month,
      analysis.createdAt.toDate().day,
    );
    final analysisId = analysis.analysisId ?? 'N/A';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Informasi Analisis',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Responsive.isMobile(context)
              ? Column(
                  children: [
                    _buildInfoField('Analysis ID', analysisId, Colors.white),
                    const SizedBox(height: 12),
                    _buildInfoField(
                      'Analysis Date',
                      '${dateFormat.day}/${dateFormat.month}/${dateFormat.year}',
                      Colors.white,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoField('Method', 'TOPSIS', Colors.white),
                    const SizedBox(height: 12),
                    _buildInfoField(
                      'Alternatives Processed',
                      '${analysis.totalItems} items',
                      Colors.white,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoField(
                            'Analysis ID',
                            analysisId,
                            Colors.white,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoField(
                            'Analysis Date',
                            '${dateFormat.day}/${dateFormat.month}/${dateFormat.year}',
                            Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoField('Method', 'TOPSIS', Colors.white),
                          const SizedBox(height: 16),
                          _buildInfoField(
                            'Alternatives Processed',
                            '${analysis.totalItems} items',
                            Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTopRankItemsPanel(
    BuildContext context,
    List<Map<String, dynamic>> top3,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.hondaRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.hondaRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'TOP RANK ITEMS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Responsive.isMobile(context)
              ? Column(
                  children: top3.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildRankCard(item),
                    );
                  }).toList(),
                )
              : Row(
                  children: top3.map((item) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildRankCard(item),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildRankCard(Map<String, dynamic> item) {
    final rank = item['rank'];
    final rankColor = _getRankColor(rank);
    final rankIcon = _getRankIcon(rank);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [rankColor.withOpacity(0.1), rankColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rankColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: rankColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(rankIcon, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 16),
          Text(
            'Rank $rank',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: rankColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item['nama_barang']?.toString() ?? 'Tidak ada nama',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Skor: ${(item['nilai_preferensi'] as double).toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.hondaRed;
    }
  }

  String _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '🏆';
    }
  }

  Widget _buildCriteriaSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.hondaRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  color: AppColors.hondaRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Kriteria Yang Digunakan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: analysis.criteria.map((c) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.hondaRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.hondaRed.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (c['name']?.toString() ?? 'N/A').replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.hondaRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(c['weight'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingTable(List<Map<String, dynamic>> sortedResults) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.hondaRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.table_chart_rounded,
                  color: AppColors.hondaRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tabel Perankingan Lengkap',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(Get.context!).size.width - 48,
              ),
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 16,
                headingRowHeight: 56,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 70,
                headingRowColor: WidgetStateProperty.all(
                  AppColors.hondaRed.withOpacity(0.08),
                ),
                border: TableBorder.all(color: AppColors.border, width: 1),
                columns: const [
                  DataColumn(
                    label: _TableHeader('Rank', Icons.format_list_numbered),
                  ),
                  DataColumn(label: _TableHeader('ID Barang', Icons.qr_code)),
                  DataColumn(
                    label: _TableHeader('Nama Barang', Icons.inventory_2),
                  ),
                  DataColumn(label: _TableHeader('Stok Min', Icons.looks_one)),
                  DataColumn(
                    label: _TableHeader('Stok Saat Ini', Icons.looks_two),
                  ),
                  DataColumn(
                    label: _TableHeader('Lead Time (Hari)', Icons.access_time),
                  ),
                  DataColumn(label: _TableHeader('Total Keluar', Icons.output)),
                  DataColumn(label: _TableHeader('Frekuensi', Icons.update)),
                  DataColumn(label: _TableHeader('Status', Icons.info)),
                  DataColumn(
                    label: _TableHeader('Skor TOPSIS', Icons.analytics),
                  ),
                ],
                rows: sortedResults.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color>((
                      Set<WidgetState> states,
                    ) {
                      if (index.isEven) {
                        return AppColors.softPink.withOpacity(0.2);
                      }
                      return Colors.white;
                    }),
                    cells: [
                      DataCell(Text(item['rank']?.toString() ?? '-')),
                      DataCell(Text(item['id_barang']?.toString() ?? '-')),
                      DataCell(Text(item['nama_barang']?.toString() ?? '-')),
                      DataCell(Text(item['stok_minimum']?.toString() ?? '0')),
                      DataCell(Text(item['stok_sekarang']?.toString() ?? '0')),
                      DataCell(Text(item['lead_time']?.toString() ?? '0')),
                      DataCell(Text(item['total_keluar']?.toString() ?? '-')),
                      DataCell(
                        Text(item['frekuensi_keluar']?.toString() ?? '-'),
                      ),
                      DataCell(
                        _buildStatusCell(
                          item['status_stok']?.toString() ?? 'Unknown',
                        ),
                      ),
                      DataCell(
                        Text(
                          (item['nilai_preferensi'] as double?)
                                  ?.toStringAsFixed(4) ??
                              '0.0000',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.hondaRed,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    Color bgColor;

    switch (status) {
      case 'Aman':
        bgColor = AppColors.success;
        break;
      case 'Menipis':
        bgColor = AppColors.warning;
        break;
      case 'Kritis':
        bgColor = AppColors.error;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.hondaRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: AppColors.hondaRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Aksi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Responsive.isMobile(context)
              ? Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('KEMBALI'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadPdf(),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('DOWNLOAD PDF'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.hondaRed,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('KEMBALI'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadPdf(),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('DOWNLOAD PDF'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.hondaRed,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf() async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColors.hondaRed),
        ),
        barrierDismissible: false,
      );

      await PdfService.generateAndDownloadTopsisPdf(analysis);

      Get.back();

      Get.snackbar(
        'Berhasil',
        'PDF berhasil diunduh',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.back();

      Get.snackbar(
        'Error',
        'Gagal mengunduh PDF: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}

class _TableHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TableHeader(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.hondaRed),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.hondaRed,
          ),
        ),
      ],
    );
  }
}
