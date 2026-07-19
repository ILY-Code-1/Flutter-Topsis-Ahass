// [DISABLED FOR TESTING - Firebase] import 'dart:convert';
// [DISABLED FOR TESTING - Firebase] import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/analisis_topsis_model.dart';
import '../../../models/item_model.dart';
import '../../../models/barang_keluar_model.dart';
import '../../../services/item_service.dart';
import '../../../services/topsis_service.dart';
import '../../../services/topsis_calculator.dart';

class TopsisController extends GetxController {
  // [STATIC-MODE] Set true untuk pakai data static (alternatif.json), false untuk Firebase
  static const bool useStaticData = false;

  final TopsisCalculator _calculator = TopsisCalculator();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;

  Future<void> runAnalysis({int? month, int? year}) async {
    try {
      isLoading.value = true;

      final now = DateTime.now();
      final analysisMonth = month ?? now.month;
      final analysisYear = year ?? now.year;

      final bool isCurrentPeriod =
          analysisMonth == now.month && analysisYear == now.year;

      List<ItemModel> currentItems;

      if (isCurrentPeriod) {
        currentItems = await _fetchItems();
        if (currentItems.isEmpty) {
          throw Exception('No items found to analyze');
        }

        if (!useStaticData) {
          await Get.find<TopsisService>().createSnapshot(
            currentItems,
            analysisMonth,
            analysisYear,
          );
        }
      } else {
        final snapshot = await Get.find<TopsisService>().getSnapshot(
          analysisMonth,
          analysisYear,
        );
        if (snapshot == null) {
          throw Exception(
            'Belum ada data snapshot untuk bulan $analysisMonth tahun $analysisYear. '
            'Jalankan analisis saat bulan tersebut terlebih dahulu.',
          );
        }
        currentItems = snapshot.items;
        if (currentItems.isEmpty) {
          throw Exception('Snapshot kosong untuk periode yang dipilih');
        }
      }

      final itemStats = await _fetchItemStats(analysisMonth, analysisYear);

      final matrix = currentItems.map((item) {
        final stats = itemStats[item.idBarang] ?? [];
        final totalKeluar = stats.fold<int>(0, (sum, qty) => sum + qty);
        final frekuensiKeluar = stats.length;

        return [
          item.stokSekarang.toDouble(),
          totalKeluar.toDouble(),
          frekuensiKeluar.toDouble(),
        ];
      }).toList();

      final normalizedMatrix = _calculator.normalizeMatrix(matrix);

      final weights = [0.30, 0.45, 0.25];
      final weightedMatrix = _calculator.applyWeights(
        normalizedMatrix,
        weights,
      );

      final idealSolutions = _calculator.getIdealSolutions(weightedMatrix);
      final positiveIdeal = idealSolutions[0];
      final negativeIdeal = idealSolutions[1];

      final distances = _calculator.calculateDistances(
        weightedMatrix,
        positiveIdeal,
        negativeIdeal,
      );

      final preferenceValues = _calculator.calculatePreferenceValues(distances);

      final rankedItems = _rankItems(currentItems, preferenceValues, itemStats);

      final analysis = AnalisisTopsisModel(
        periodeBulan: analysisMonth,
        periodeTahun: analysisYear,
        createdAt: Timestamp.now(),
        totalItems: currentItems.length,
        criteria: [
          {'name': 'stok_sekarang', 'type': 'cost', 'weight': 0.30},
          {'name': 'total_keluar', 'type': 'benefit', 'weight': 0.45},
          {'name': 'frekuensi_keluar', 'type': 'benefit', 'weight': 0.25},
        ],
        results: rankedItems,
      );

      if (!useStaticData) {
        await Get.find<TopsisService>().saveAnalysis(analysis);
      }

      Get.snackbar(
        'Success',
        'TOPSIS analysis completed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to run analysis: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // DATA LAYER — Switch antara Firebase dan Static JSON
  // ─────────────────────────────────────────────────────────

  Future<List<ItemModel>> _fetchItems() async {
    // [DISABLED FOR TESTING - Firebase] if (useStaticData) return _loadStaticItems();
    return await Get.find<ItemService>().getItems();
  }

  Future<Map<String, List<int>>> _fetchItemStats(int month, int year) async {
    // [DISABLED FOR TESTING - Firebase] if (useStaticData) return _loadStaticItemStats();
    return await _fetchFirestoreItemStats(month, year);
  }

  // [DISABLED FOR TESTING - Firebase] Static data methods (gunakan Firebase sebagai sumber data)
  // List<ItemModel> _loadStaticItems() {
  //   final file = File('alternatif.json');
  //   final jsonString = file.readAsStringSync();
  //   final List<dynamic> jsonData = json.decode(jsonString);
  //
  //   return jsonData.asMap().entries.map((entry) {
  //     final i = entry.key;
  //     final data = entry.value;
  //     return ItemModel(
  //       idBarang: 'STATIC_${i + 1}',
  //       namaBarang: data['alternatif'] as String,
  //       kategori: 'static',
  //       stokSekarang: data['C1'] as int,
  //       stokMinimum: 0,
  //       statusStok: 'Aman',
  //       lastUpdate: Timestamp.now(),
  //     );
  //   }).toList();
  // }

  // [DISABLED FOR TESTING - Firebase]
  // Map<String, List<int>> _loadStaticItemStats() {
  //   final file = File('alternatif.json');
  //   final jsonString = file.readAsStringSync();
  //   final List<dynamic> jsonData = json.decode(jsonString);
  //
  //   final Map<String, List<int>> stats = {};
  //   for (int i = 0; i < jsonData.length; i++) {
  //     final data = jsonData[i];
  //     final idBarang = 'STATIC_${i + 1}';
  //     final totalKeluar = data['C2'] as int;
  //     final frekuensi = data['C3'] as int;
  //     stats[idBarang] = _createStatsList(totalKeluar, frekuensi);
  //   }
  //   return stats;
  // }

  // [DISABLED FOR TESTING - Firebase]
  // List<int> _createStatsList(int totalKeluar, int frekuensi) {
  //   if (frekuensi == 0) return [];
  //   if (frekuensi == 1) return [totalKeluar];
  //   final list = List<int>.filled(frekuensi, 1);
  //   list[0] = totalKeluar - (frekuensi - 1);
  //   return list;
  // }

  Future<Map<String, List<int>>> _fetchFirestoreItemStats(
    int month,
    int year,
  ) async {
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

    final Map<String, List<int>> itemStats = {};
    for (var tx in transactions) {
      if (!itemStats.containsKey(tx.idBarang)) {
        itemStats[tx.idBarang] = [];
      }
      itemStats[tx.idBarang]!.add(tx.jumlah);
    }
    return itemStats;
  }

  // ─────────────────────────────────────────────────────────
  // TOPSIS MATH — Delegated to TopsisCalculator
  // ─────────────────────────────────────────────────────────

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

/*
 * ============================================================================
 * DOKUMENTASI PERBAIKAN - ANALISIS HISTORIS DENGAN SNAPSHOT
 * ============================================================================
 * 
 * TANGGAL: Juli 2026
 * 
 * BUG:
 * - runAnalysis() selalu menggunakan data real-time dari collection 'items'
 * - Tidak bisa melakukan analisis untuk bulan/tahun yang sudah lewat
 * - Saat pilih bulan lalu untuk analisis, data yang dipakai tetap data sekarang
 * 
 * ROOT CAUSE:
 * - Tidak ada logika untuk membedakan periode sekarang vs periode lalu
 * - Selalu fetch dari ItemService.getItems() tanpa cek snapshot
 * - Snapshot hanya dibuat, tidak pernah dibaca untuk analisis historis
 * 
 * SOLUSI YANG DITERAPKAN:
 * 1. Tambah pengecekan isCurrentPeriod (month == now.month && year == now.year)
 * 2. Jika periode sekarang:
 *    - Fetch items real-time dari ItemService
 *    - Buat snapshot untuk periode ini
 *    - Lanjutkan analisis seperti biasa
 * 3. Jika periode lalu:
 *    - Ambil items dari stock_snapshot via TopsisService.getSnapshot()
 *    - Jika snapshot tidak ada → error dengan pesan informatif
 *    - Gunakan items dari snapshot untuk decision matrix
 * 4. barang_keluar tetap di-filter berdasarkan month+year yang dipilih
 * 
 * ALUR ANALISIS:
 * Periode Sekarang → fetch real-time → create snapshot → analisis
 * Periode Lalu → read snapshot → analisis (tanpa create snapshot baru)
 * 
 * PELAJARAN:
 * - Data historis butuh mekanisme "time travel" via snapshot
 * - Snapshot harus dibuat SAAT periode berjalan, bukan setelah lewat
 * - Error message harus informatif: "Jalankan analisis saat bulan tersebut terlebih dahulu"
 * - Decision matrix untuk periode lalu pakai stok dari snapshot, bukan stok real-time
 * 
 * PENTING:
 * - stok_sekarang di decision matrix berasal dari snapshot untuk periode lalu
 * - total_keluar dan frekuensi_keluar berasal dari barang_keluar yang di-filter bulan/tahun
 * - Jika snapshot belum ada untuk periode lalu, user harus menjalankan analisis
 *   saat periode tersebut masih berjalan
 * 
 * ============================================================================
 */
