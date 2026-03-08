import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../models/item_model.dart';

class StaffDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxInt totalItems = 0.obs;
  final RxInt totalBarangMasuk = 0.obs;
  final RxInt frekuensiBarangMasuk = 0.obs;
  final RxInt totalBarangKeluar = 0.obs;
  final RxInt frekuensiBarangKeluar = 0.obs;
  final RxInt totalCriticalItems = 0.obs;
  final RxList<ItemModel> criticalItems = <ItemModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;

      // Fetch total items
      final itemsSnapshot = await _firestore.collection('items').get();
      totalItems.value = itemsSnapshot.docs.length;

      // Calculate critical items
      int criticalCount = 0;
      List<ItemModel> criticalList = [];

      for (var doc in itemsSnapshot.docs) {
        final item = ItemModel.fromMap(doc.data());
        if (item.statusStok == 'Kritis') {
          criticalCount++;
          criticalList.add(item);
        }
      }

      totalCriticalItems.value = criticalCount;
      criticalItems.value = criticalList;

      // Fetch barang masuk data (frekuensi dan total quantity)
      final barangMasukSnapshot = await _firestore
          .collection('barang_masuk')
          .get();
      frekuensiBarangMasuk.value = barangMasukSnapshot.docs.length;
      int masukCount = 0;
      for (var doc in barangMasukSnapshot.docs) {
        masukCount += (doc.data()['jumlah'] as int? ?? 0);
      }
      totalBarangMasuk.value = masukCount;

      // Fetch barang keluar data (frekuensi dan total quantity)
      final barangKeluarSnapshot = await _firestore
          .collection('barang_keluar')
          .get();
      frekuensiBarangKeluar.value = barangKeluarSnapshot.docs.length;
      int keluarCount = 0;
      for (var doc in barangKeluarSnapshot.docs) {
        keluarCount += (doc.data()['jumlah'] as int? ?? 0);
      }
      totalBarangKeluar.value = keluarCount;

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Gagal memuat data dashboard: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshDashboard() async {
    await fetchDashboardData();
  }

  void navigateToKelolaStock() {
    Get.toNamed('/staff-stock');
  }

  void navigateToBarangMasuk() {
    Get.toNamed('/barang-masuk');
  }

  void navigateToBarangKeluar() {
    Get.toNamed('/barang-keluar');
  }
}
