import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../models/item_model.dart';
import '../../../services/item_service.dart';

class ItemManagementController extends GetxController {
  final ItemService _itemService = Get.find<ItemService>();

  final isLoading = false.obs;
  final items = <ItemModel>[].obs;

  // Selected month filter (for future implementation)
  final selectedMonth = ''.obs;

  // Controllers untuk form
  final idBarangController = TextEditingController();
  final namaBarangController = TextEditingController();
  final kategoriController = TextEditingController();
  final stokSekarangController = TextEditingController();
  final stokMinimumController = TextEditingController();
  final leadTimeController = TextEditingController();
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
    leadTimeController.dispose();
    super.onClose();
  }

  // Fetch semua items dari Firebase
  Future<void> fetchItems() async {
    try {
      isLoading.value = true;

      final fetchedItems = await _itemService.getItems();
      items.value = fetchedItems;
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

  // Reset form
  void resetForm() {
    editingItemId = null;
    idBarangController.clear();
    namaBarangController.clear();
    kategoriController.clear();
    stokSekarangController.clear();
    stokMinimumController.clear();
    leadTimeController.clear();
  }

  // Load data ke form untuk edit
  void loadItemToForm(ItemModel item) {
    editingItemId = item.idBarang;
    idBarangController.text = item.idBarang;
    namaBarangController.text = item.namaBarang;
    kategoriController.text = item.kategori;
    stokSekarangController.text = item.stokSekarang.toString();
    stokMinimumController.text = item.stokMinimum.toString();
    leadTimeController.text = item.leadTime.toString();
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
      final leadTime = int.parse(leadTimeController.text);

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
        leadTime: leadTime,
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
            colorText: Colors.red.shade900,
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
        colorText: Colors.red.shade900,
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
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
