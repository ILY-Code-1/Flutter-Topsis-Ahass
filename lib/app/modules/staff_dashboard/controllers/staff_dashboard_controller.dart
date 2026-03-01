import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class StaffDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxInt totalItems = 0.obs;
  final RxInt totalBarangMasuk = 0.obs;
  final RxInt totalBarangKeluar = 0.obs;
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

      // Calculate barang masuk and barang keluar totals
      int masukCount = 0;
      int keluarCount = 0;

      for (var doc in itemsSnapshot.docs) {
        final data = doc.data();
        masukCount += (data['barangMasuk'] as int? ?? 0);
        keluarCount += (data['barangKeluar'] as int? ?? 0);
      }

      totalBarangMasuk.value = masukCount;
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
    Get.toNamed('/item-management');
  }

  void navigateToBarangMasuk() {
    Get.toNamed('/form');
  }

  void navigateToBarangKeluar() {
    Get.toNamed('/form');
  }
}
