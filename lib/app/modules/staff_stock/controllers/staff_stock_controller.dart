import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../models/item_model.dart';
import '../../../services/item_service.dart';

/// Controller for Staff Stock Monitoring (Read-Only)
///
/// Staff users can only view stock items without modification capabilities.
/// Supports month-based filtering with transaction aggregation.
class StaffStockController extends GetxController {
  final ItemService _itemService = Get.find<ItemService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final items = <ItemModel>[].obs;
  final filteredItems = <ItemModel>[].obs;

  // Selected month filter
  final selectedMonth = ''.obs;

  // Transaction data for month filtering (month -> id_barang -> count)
  final barangMasukCount = <String, Map<String, int>>{}.obs;
  final barangKeluarCount = <String, Map<String, int>>{}.obs;

  // Current stock display (after filtering)
  final displayItems = <ItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
    fetchTransactions();
  }

  /// Fetch all items from Firestore
  Future<void> fetchItems() async {
    try {
      isLoading.value = true;

      final fetchedItems = await _itemService.getItems();
      items.value = fetchedItems;

      // Apply filter if month is selected
      applyMonthFilter();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data item: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch transaction data for month filtering
  Future<void> fetchTransactions() async {
    try {
      // Fetch barang_masuk transactions
      final masukSnapshot = await _firestore
          .collection('barang_masuk')
          .orderBy('tanggal', descending: false)
          .get();

      barangMasukCount.clear();
      for (var doc in masukSnapshot.docs) {
        final data = doc.data();
        final idBarang = data['id_barang'] as String?;
        if (idBarang == null) continue;

        final tanggal = data['tanggal'] as Timestamp;
        final month = _getMonthFromTimestamp(tanggal);

        // Initialize month map if needed
        if (!barangMasukCount.containsKey(month)) {
          barangMasukCount[month] = {};
        }

        // Count per item
        barangMasukCount[month]![idBarang] =
            (barangMasukCount[month]![idBarang] ?? 0) +
            (data['jumlah'] as num).toInt();
      }

      // Fetch barang_keluar transactions
      final keluarSnapshot = await _firestore
          .collection('barang_keluar')
          .orderBy('tanggal', descending: false)
          .get();

      barangKeluarCount.clear();
      for (var doc in keluarSnapshot.docs) {
        final data = doc.data();
        final idBarang = data['id_barang'] as String?;
        if (idBarang == null) continue;

        final tanggal = data['tanggal'] as Timestamp;
        final month = _getMonthFromTimestamp(tanggal);

        // Initialize month map if needed
        if (!barangKeluarCount.containsKey(month)) {
          barangKeluarCount[month] = {};
        }

        // Count per item
        barangKeluarCount[month]![idBarang] =
            (barangKeluarCount[month]![idBarang] ?? 0) +
            (data['jumlah'] as num).toInt();
      }

      applyMonthFilter();
    } catch (e) {
      // If transaction fetch fails, we still show items without filtering
      Get.snackbar(
        'Warning',
        'Gagal memuat data transaksi. Filter tidak tersedia.',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Apply month filter to items
  void applyMonthFilter() {
    if (selectedMonth.value.isEmpty || selectedMonth.value == 'Semua') {
      // Show all items
      displayItems.value = items;
    } else {
      // Filter items that had transactions in selected month
      final month = selectedMonth.value;
      displayItems.value = items.where((item) {
        // Check if item had barang_masuk in this month
        final hasMasuk = barangMasukCount.containsKey(month) &&
            barangMasukCount[month]!.containsKey(item.idBarang) &&
            barangMasukCount[month]![item.idBarang]! > 0;

        // Check if item had barang_keluar in this month
        final hasKeluar = barangKeluarCount.containsKey(month) &&
            barangKeluarCount[month]!.containsKey(item.idBarang) &&
            barangKeluarCount[month]![item.idBarang]! > 0;

        // Show item if it has any transaction in the selected month
        return hasMasuk || hasKeluar;
      }).toList();
    }
  }

  /// Get month name from timestamp
  String _getMonthFromTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei',
      'Juni', 'Juli', 'Agustus', 'September', 'Oktober',
      'November', 'Desember'
    ];
    return months[date.month - 1];
  }

  /// Format tanggal untuk display
  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Get status badge color
  Color getStatusColor(String statusStok) {
    switch (statusStok) {
      case 'Aman':
        return const Color(0xFF3DA35D); // Green
      case 'Menipis':
        return const Color(0xFFFFB33F); // Orange
      case 'Kritis':
        return const Color(0xFFC00707); // Red
      default:
        return Colors.grey;
    }
  }

  /// Get status text color (white for colored badges)
  Color getStatusTextColor(String statusStok) {
    return Colors.white;
  }

  /// Get transaction info for an item in selected month
  String getMasukCount(String idBarang) {
    final month = selectedMonth.value;
    if (month.isEmpty || month == 'Semua') return '-';
    if (!barangMasukCount.containsKey(month)) return '-';
    final monthMasuk = barangMasukCount[month]!;
    if (!monthMasuk.containsKey(idBarang)) return '-';
    return monthMasuk[idBarang]!.toString();
  }

  /// Get transaction info for an item in selected month
  String getKeluarCount(String idBarang) {
    final month = selectedMonth.value;
    if (month.isEmpty || month == 'Semua') return '-';
    if (!barangKeluarCount.containsKey(month)) return '-';
    final monthKeluar = barangKeluarCount[month]!;
    if (!monthKeluar.containsKey(idBarang)) return '-';
    return monthKeluar[idBarang]!.toString();
  }
}
