import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/analisis_topsis_model.dart';

class PdfService {
  static Future<void> generateAndDownloadTopsisPdf(
    AnalisisTopsisModel analysis,
  ) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          // ✅ FIX #1: MultiPage build harus return List<pw.Widget>, bukan pw.Column
          build: (pw.Context context) => [
            _buildHeader(),
            pw.SizedBox(height: 24),
            _buildAnalysisInfo(analysis),
            pw.SizedBox(height: 24),
            _buildTopRankItems(analysis),
            pw.SizedBox(height: 24),
            _buildCriteria(analysis),
            pw.SizedBox(height: 24),
            ..._buildRankingTable(analysis),
            pw.SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      );

      // ✅ FIX #2: onLayout harus return Future<Uint8List> via pdf.save()
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            'TOPSIS_Analysis_${analysis.analysisId}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.red800,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'AHASS AutoPart Monitor',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Laporan Analisis TOPSIS',
            style: pw.TextStyle(fontSize: 16, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAnalysisInfo(AnalisisTopsisModel analysis) {
    final dateFormat = DateFormat('dd MMMM yyyy HH:mm');

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Informasi Analisis',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('ID Analisis', analysis.analysisId ?? '-'),
                    pw.SizedBox(height: 8),
                    _buildInfoRow(
                      'Tanggal',
                      dateFormat.format(analysis.createdAt.toDate()),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Metode', 'TOPSIS'),
                    pw.SizedBox(height: 8),
                    _buildInfoRow(
                      'Total Alternatif',
                      analysis.totalItems.toString(),
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

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  static pw.Widget _buildTopRankItems(AnalisisTopsisModel analysis) {
    final sortedResults = List<Map<String, dynamic>>.from(analysis.results);
    sortedResults.sort(
      (a, b) => ((b['nilai_preferensi'] as num?)?.toDouble() ?? 0.0).compareTo(
        (a['nilai_preferensi'] as num?)?.toDouble() ?? 0.0,
      ),
    );
    final top3 = sortedResults.take(3).toList();

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TOP RANK ITEMS',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 16),
          ...top3.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final rank = index + 1;

            // ✅ FIX #3: Hapus emoji, font PDF tidak support unicode emoji
            // ✅ FIX #4: Pisahkan bg color dan text color agar tidak invisible
            PdfColor bgColor;
            PdfColor textColor;
            String rankLabel;

            if (rank == 1) {
              bgColor = PdfColors.amber100;
              textColor = PdfColors.amber800;
              rankLabel = 'Rank #1';
            } else if (rank == 2) {
              bgColor = PdfColors.grey200;
              textColor = PdfColors.grey700;
              rankLabel = 'Rank #2';
            } else {
              bgColor = PdfColors.orange100;
              textColor = PdfColors.orange800;
              rankLabel = 'Rank #3';
            }

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: bgColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                children: [
                  pw.SizedBox(
                    width: 60,
                    child: pw.Text(
                      rankLabel,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          item['nama_barang']?.toString() ?? 'Tidak ada nama',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Skor: ${(item['nilai_preferensi'] as double?)?.toStringAsFixed(4) ?? '0.0000'}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  static pw.Widget _buildCriteria(AnalisisTopsisModel analysis) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Kriteria Yang Digunakan',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 16),
          ...analysis.criteria.map((c) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    '- ',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.blue700,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      (c['name']?.toString() ?? 'N/A')
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                  ),
                  pw.Text(
                    'Bobot: ${(c['weight'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildRankingTable(AnalisisTopsisModel analysis) {
    final headers = [
      'Rank',
      'ID Barang',
      'Nama Barang',
      'Stok Min',
      'Stok Skrg',
      'Lead Time',
      'Total Keluar',
      'Frekuensi',
      'Status',
      'Skor TOPSIS',
    ];

    return [
      pw.Text(
        'Tabel Perankingan Lengkap',
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
      pw.SizedBox(height: 16),
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        columnWidths: const {
          0: pw.FixedColumnWidth(30),
          1: pw.FixedColumnWidth(70),
          2: pw.FlexColumnWidth(2),
          3: pw.FixedColumnWidth(45),
          4: pw.FixedColumnWidth(45),
          5: pw.FixedColumnWidth(45),
          6: pw.FixedColumnWidth(50),
          7: pw.FixedColumnWidth(55),
          8: pw.FixedColumnWidth(60),
          9: pw.FixedColumnWidth(65),
        },
        children: [
          // Header row
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.red800),
            children: headers.map((header) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  header,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              );
            }).toList(),
          ),
          // Data rows
          ...analysis.results.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final bgColor = i.isEven ? PdfColors.white : PdfColors.grey50;

            final cells = [
              item['rank']?.toString() ?? '-',
              item['id_barang']?.toString() ?? '-',
              item['nama_barang']?.toString() ?? '-',
              item['stok_minimum']?.toString() ?? '0',
              item['stok_sekarang']?.toString() ?? '0',
              item['lead_time']?.toString() ?? '0',
              item['total_keluar']?.toString() ?? '-',
              item['frekuensi_keluar']?.toString() ?? '-',
              item['status_stok']?.toString() ?? 'Unknown',
              (item['nilai_preferensi'] as double?)?.toStringAsFixed(4) ??
                  '0.0000',
            ];

            return pw.TableRow(
              decoration: pw.BoxDecoration(color: bgColor),
              children: cells.map((cell) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(cell, style: const pw.TextStyle(fontSize: 9)),
                );
              }).toList(),
            );
          }).toList(),
        ],
      ),
    ];
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Text(
            'Dibuat pada: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '© 2026 AHASS AutoPart Monitor. All rights reserved.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }
}
