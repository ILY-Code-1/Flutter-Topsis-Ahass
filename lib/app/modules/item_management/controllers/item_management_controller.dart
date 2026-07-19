import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../models/item_model.dart';
import '../../../services/item_service.dart';
import '../../../services/topsis_service.dart';

class ItemManagementController extends GetxController {
  final ItemService _itemService = Get.find<ItemService>();
  final TopsisService _topsisService = Get.find<TopsisService>();

  final isLoading = false.obs;
  final items = <ItemModel>[].obs;

  final selectedMonth = ''.obs;
  final selectedYear = DateTime.now().year.obs;
  final snapshotExists = false.obs;
  final isViewingHistorical = false.obs;

  static const Map<String, int> monthMap = {
    'Januari': 1,
    'Februari': 2,
    'Maret': 3,
    'April': 4,
    'Mei': 5,
    'Juni': 6,
    'Juli': 7,
    'Agustus': 8,
    'September': 9,
    'Oktober': 10,
    'November': 11,
    'Desember': 12,
  };

  static const List<int> availableYears = [2024, 2025, 2026];

  // Controllers untuk form
  final idBarangController = TextEditingController();
  final namaBarangController = TextEditingController();
  final kategoriController = TextEditingController();
  final stokSekarangController = TextEditingController();
  final stokMinimumController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Mode edit atau tambah
  String? editingItemId;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  @override
  void onClose() {
    idBarangController.dispose();
    namaBarangController.dispose();
    kategoriController.dispose();
    stokSekarangController.dispose();
    stokMinimumController.dispose();
    super.onClose();
  }

  Future<void> fetchItems() async {
    try {
      isLoading.value = true;
      snapshotExists.value = false;

      final isHistorical =
          selectedMonth.value.isNotEmpty && selectedMonth.value != 'Semua';
      isViewingHistorical.value = isHistorical;

      if (isHistorical) {
        final month = monthMap[selectedMonth.value] ?? DateTime.now().month;
        final year = selectedYear.value;

        final snapshot = await _topsisService.getSnapshot(month, year);
        if (snapshot != null) {
          items.value = snapshot.items;
          snapshotExists.value = true;
        } else {
          items.value = [];
          snapshotExists.value = false;
        }
      } else {
        final fetchedItems = await _itemService.getItems();
        items.value = fetchedItems;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data item: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onMonthChanged(String? value) {
    selectedMonth.value = value ?? '';
    fetchItems();
  }

  void onYearChanged(int? value) {
    if (value != null) {
      selectedYear.value = value;
      fetchItems();
    }
  }

  // Reset form
  void resetForm() {
    editingItemId = null;
    idBarangController.clear();
    namaBarangController.clear();
    kategoriController.clear();
    stokSekarangController.clear();
    stokMinimumController.clear();
  }

  // Load data ke form untuk edit
  void loadItemToForm(ItemModel item) {
    editingItemId = item.idBarang;
    idBarangController.text = item.idBarang;
    namaBarangController.text = item.namaBarang;
    kategoriController.text = item.kategori;
    stokSekarangController.text = item.stokSekarang.toString();
    stokMinimumController.text = item.stokMinimum.toString();
  }

  // Format angka ke Rupiah
  String formatRupiah(int? value) {
    if (value == null) return '-';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  // Format tanggal
  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Get item by ID
  ItemModel? getItemById(String idBarang) {
    try {
      return items.firstWhere((item) => item.idBarang == idBarang);
    } catch (e) {
      return null;
    }
  }

  // Save item (Create or Update)
  Future<void> saveItem() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final idBarang = idBarangController.text.trim();
      final namaBarang = namaBarangController.text.trim();
      final kategori = kategoriController.text.trim();
      final stokSekarang = int.parse(stokSekarangController.text);
      final stokMinimum = int.parse(stokMinimumController.text);

      // Calculate status stok automatically
      final statusStok = ItemModel.calculateStatusStok(
        stokSekarang,
        stokMinimum,
      );

      final item = ItemModel(
        idBarang: idBarang,
        namaBarang: namaBarang,
        kategori: kategori,
        stokSekarang: stokSekarang,
        stokMinimum: stokMinimum,
        statusStok: statusStok,
        lastUpdate: Timestamp.now(),
      );

      if (editingItemId == null) {
        // Check for duplicate ID
        final idExists = await _itemService.checkIdBarangExists(idBarang);
        if (idExists) {
          Get.snackbar(
            'Error',
            'ID Barang "$idBarang" sudah ada. Gunakan ID lain.',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          isLoading.value = false;
          return;
        }

        // Create new item
        await _itemService.addItem(item);

        Get.snackbar(
          'Berhasil',
          'Item berhasil ditambahkan',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        // Update existing item
        await _itemService.updateItem(item);

        Get.snackbar(
          'Berhasil',
          'Item berhasil diperbarui',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.TOP,
        );
      }

      // Refresh list
      await fetchItems();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan item: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete item
  void deleteItem(String idBarang, String namaBarang) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus item "$namaBarang"?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              await _deleteItemConfirmed(idBarang);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItemConfirmed(String idBarang) async {
    try {
      isLoading.value = true;

      await _itemService.deleteItem(idBarang);

      Get.snackbar(
        'Berhasil',
        'Item berhasil dihapus',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.TOP,
      );

      // Refresh list
      await fetchItems();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus item: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

/*
 * ============================================================================
 * DOKUMENTASI PERBAIKAN BUG - FILTER BULAN & TAHUN
 * ============================================================================
 * 
 * TANGGAL: Juli 2026
 * 
 * BUG:
 * - Filter bulan tidak berfungsi, data tidak berubah saat memilih bulan berbeda
 * - Saat pilih bulan yang belum ada data (misal Januari), tetap menampilkan data
 * - Tidak ada empty state yang informatif
 * 
 * ROOT CAUSE:
 * - selectedMonth hanya di-set tapi tidak pernah digunakan untuk filter data
 * - fetchItems() selalu fetch dari collection 'items' tanpa memandang bulan
 * - Tidak ada integrasi dengan collection 'stock_snapshot' untuk data historis
 * 
 * SOLUSI YANG DITERAPKAN:
 * 1. Tambah selectedYear observable untuk filter tahun
 * 2. Tambah snapshotExists dan isViewingHistorical untuk tracking state
 * 3. Ubah fetchItems():
 *    - Jika month dipilih & bukan "Semua" → fetch dari stock_snapshot
 *    - Jika "Semua" atau kosong → fetch dari items collection (real-time)
 * 4. Tambah onMonthChanged() dan onYearChanged() yang trigger fetchItems()
 * 5. Tambah static monthMap dan availableYears untuk konversi bulan
 * 
 * PELAJARAN:
 * - State observable harus selalu digunakan, bukan hanya di-set
 * - Filter UI harus trigger data refresh
 * - Data historis butuh mekanisme snapshot, tidak bisa hanya pakai data real-time
 * - Empty state harus informatif dan tetap membiarkan user berinteraksi dengan filter
 * 
 * STRUKTUR DATA:
 * - stock_snapshot collection menyimpan snapshot items per bulan/tahun
 * - Format: { bulan: int, tahun: int, created_at: Timestamp, items: List<ItemModel> }
 * - Snapshot dibuat saat runAnalysis() untuk periode berjalan
 * 
 * ============================================================================
 */
