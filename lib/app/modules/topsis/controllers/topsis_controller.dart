import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../models/analisis_topsis_model.dart';
import '../../../models/item_model.dart';
import '../../../models/stock_snapshot_model.dart';
import '../../../models/barang_keluar_model.dart';
import '../../../services/item_service.dart';
import '../../../services/topsis_service.dart';

class TopsisController extends GetxController {
  final ItemService _itemService = Get.find<ItemService>();
  final TopsisService _topsisService = Get.find<TopsisService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;

  Future<void> runAnalysis() async {
    try {
      isLoading.value = true;

      final now = DateTime.now();
      final month = now.month;
      final year = now.year;

      // Step 1: Always fetch the latest items to ensure synchronized stock
      final currentItems = await _itemService.getItems();
      if (currentItems.isEmpty) {
        throw Exception('No items found to analyze');
      }

      // Step 1.1: Create or update snapshot for the current month
      // This ensures the snapshot also stays relatively updated with the last analysis
      await _topsisService.createSnapshot(currentItems, month, year);

      // Step 1.2: Fetch current month's transactions to sync total_keluar and frekuensi
      final firstDayOfMonth = DateTime(year, month, 1);
      final lastDayOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

      final barangKeluarSnapshot = await _firestore
          .collection('barang_keluar')
          .where(
            'tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
          )
          .where(
            'tanggal',
            isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth),
          )
          .get();

      final List<BarangKeluarModel> transactions = barangKeluarSnapshot.docs
          .map((doc) => BarangKeluarModel.fromMap(doc.data()))
          .toList();

      // Create a map for quick lookup
      final Map<String, List<int>> itemStats = {};
      for (var tx in transactions) {
        if (!itemStats.containsKey(tx.idBarang)) {
          itemStats[tx.idBarang] = [];
        }
        itemStats[tx.idBarang]!.add(tx.jumlah);
      }

      // Step 2: Build decision matrix using real-time items (4 criteria: stok_sekarang, stok_minimum, total_keluar, frekuensi_keluar)
      // Criteria:
      // 0: stok_sekarang (cost)
      // 1: stok_minimum (benefit)
      // 2: total_keluar (benefit)
      // 3: frekuensi_keluar (benefit)
      final matrix = currentItems.map((item) {
        final stats = itemStats[item.idBarang] ?? [];
        final totalKeluar = stats.fold<int>(0, (sum, qty) => sum + qty);
        final frekuensiKeluar = stats.length;

        return [
          item.stokSekarang.toDouble(),
          item.stokMinimum.toDouble(),
          totalKeluar.toDouble(),
          frekuensiKeluar.toDouble(),
        ];
      }).toList();

      // Step 3: Normalize matrix
      final normalizedMatrix = _normalizeMatrix(matrix);

      // Step 4: Apply weights (adjusting to 4 criteria)
      // stok_sekarang: 0.25, stok_minimum: 0.2, total_keluar: 0.3, frekuensi_keluar: 0.25
      final weights = [0.25, 0.2, 0.3, 0.25];
      final weightedMatrix = _applyWeights(normalizedMatrix, weights);

      // Step 5: Determine ideal solutions
      final idealSolutions = _getIdealSolutions(weightedMatrix);
      final positiveIdeal = idealSolutions[0];
      final negativeIdeal = idealSolutions[1];

      // Step 6 & 7: Calculate distances
      final distances = _calculateDistances(
        weightedMatrix,
        positiveIdeal,
        negativeIdeal,
      );

      // Step 8: Calculate preference values
      final preferenceValues = _calculatePreferenceValues(distances);

      // Step 9 & 10: Rank items with synced data
      final rankedItems = _rankItems(currentItems, preferenceValues, itemStats);

      // Save analysis
      final analysis = AnalisisTopsisModel(
        periodeBulan: month,
        periodeTahun: year,
        createdAt: Timestamp.now(),
        totalItems: currentItems.length,
        criteria: [
          {'name': 'stok_sekarang', 'type': 'cost', 'weight': 0.25},
          {'name': 'stok_minimum', 'type': 'benefit', 'weight': 0.2},
          {'name': 'total_keluar', 'type': 'benefit', 'weight': 0.3},
          {'name': 'frekuensi_keluar', 'type': 'benefit', 'weight': 0.25},
        ],
        results: rankedItems,
      );

      await _topsisService.saveAnalysis(analysis);

      Get.snackbar('Success', 'TOPSIS analysis completed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to run analysis: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<List<double>> _normalizeMatrix(List<List<double>> matrix) {
    if (matrix.isEmpty) return [];
    final int colCount = matrix[0].length;
    final List<double> dividers = List.filled(colCount, 0.0);

    for (int j = 0; j < colCount; j++) {
      double sum = 0;
      for (int i = 0; i < matrix.length; i++) {
        sum += pow(matrix[i][j], 2);
      }
      dividers[j] = sqrt(sum);
      // Avoid division by zero
      if (dividers[j] == 0) dividers[j] = 1.0;
    }

    return matrix
        .map(
          (row) => row
              .asMap()
              .map((j, value) => MapEntry(j, value / dividers[j]))
              .values
              .toList(),
        )
        .toList();
  }

  List<List<double>> _applyWeights(
    List<List<double>> matrix,
    List<double> weights,
  ) {
    return matrix
        .map(
          (row) => row
              .asMap()
              .map((j, value) => MapEntry(j, value * weights[j]))
              .values
              .toList(),
        )
        .toList();
  }

  List<List<double>> _getIdealSolutions(List<List<double>> matrix) {
    if (matrix.isEmpty) return [[], []];
    final int colCount = matrix[0].length;
    final positiveIdeal = List<double>.filled(colCount, 0.0);
    final negativeIdeal = List<double>.filled(colCount, 0.0);

    for (int j = 0; j < colCount; j++) {
      List<double> column = matrix.map((row) => row[j]).toList();
      if (j == 0) {
        // Cost criteria (stok_sekarang)
        positiveIdeal[j] = column.reduce(min);
        negativeIdeal[j] = column.reduce(max);
      } else {
        // Benefit criteria (stok_minimum, total_keluar, frekuensi_keluar)
        positiveIdeal[j] = column.reduce(max);
        negativeIdeal[j] = column.reduce(min);
      }
    }
    return [positiveIdeal, negativeIdeal];
  }

  List<List<double>> _calculateDistances(
    List<List<double>> matrix,
    List<double> positiveIdeal,
    List<double> negativeIdeal,
  ) {
    return matrix.map((row) {
      double dPlus = 0;
      double dMinus = 0;
      for (int j = 0; j < row.length; j++) {
        dPlus += pow(row[j] - positiveIdeal[j], 2);
        dMinus += pow(row[j] - negativeIdeal[j], 2);
      }
      return [sqrt(dPlus), sqrt(dMinus)];
    }).toList();
  }

  List<double> _calculatePreferenceValues(List<List<double>> distances) {
    return distances.map((d) {
      final dPlus = d[0];
      final dMinus = d[1];
      if ((dPlus + dMinus) == 0) return 0.0;
      return dMinus / (dPlus + dMinus);
    }).toList();
  }

  List<Map<String, dynamic>> _rankItems(
    List<ItemModel> items,
    List<double> preferenceValues,
    Map<String, List<int>> itemStats,
  ) {
    final rankedItems = items
        .asMap()
        .map((i, item) {
          final stats = itemStats[item.idBarang] ?? [];
          final totalKeluar = stats.fold<int>(0, (sum, qty) => sum + qty);
          final frekuensiKeluar = stats.length;

          return MapEntry(i, {
            'id_barang': item.idBarang,
            'nama_barang': item.namaBarang,
            'nilai_preferensi': preferenceValues[i],
            'stok_sekarang': item.stokSekarang,
            'stok_minimum': item.stokMinimum,
            'lead_time': item.leadTime,
            'total_keluar': totalKeluar,
            'frekuensi_keluar': frekuensiKeluar,
            'status_stok': item.statusStok,
          });
        })
        .values
        .toList();

    rankedItems.sort(
      (a, b) => (b['nilai_preferensi'] as double).compareTo(
        a['nilai_preferensi'] as double,
      ),
    );

    return rankedItems.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      return {...item, 'rank': i + 1};
    }).toList();
  }
}
