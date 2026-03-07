import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/barang_keluar_model.dart';
import '../../../models/item_model.dart';
import '../../../services/barang_keluar_service.dart';
import '../../../services/item_service.dart';

class BarangKeluarController extends GetxController {
  final BarangKeluarService _barangKeluarService =
      Get.find<BarangKeluarService>();
  final ItemService _itemService = Get.find<ItemService>();

  final isLoading = false.obs;
  final isSaving = false.obs;

  final allRecords = <BarangKeluarModel>[].obs;
  final displayRecords = <BarangKeluarModel>[].obs;
  final selectedMonth = ''.obs;

  final items = <ItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading.value = true;
      final records = await _barangKeluarService.getBarangKeluar();
      allRecords.value = records;
      final fetchedItems = await _itemService.getItems();
      items.value = fetchedItems;
      applyMonthFilter();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyMonthFilter() {
    if (selectedMonth.value.isEmpty || selectedMonth.value == 'Semua') {
      displayRecords.value = allRecords;
      return;
    }

    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final monthIndex = months.indexOf(selectedMonth.value);
    if (monthIndex == -1) {
      displayRecords.value = allRecords;
      return;
    }

    displayRecords.value = allRecords.where((r) {
      final date = r.tanggal.toDate();
      return date.month == monthIndex + 1;
    }).toList();
  }

  Future<void> addBarangKeluar(BarangKeluarModel record) async {
    try {
      isSaving.value = true;
      await _barangKeluarService.addBarangKeluar(record);
      Get.snackbar(
        'Berhasil',
        'Barang keluar berhasil dicatat',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.TOP,
      );
      await fetchAll();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: Gagal menambah barang keluar: Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSaving.value = false;
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
