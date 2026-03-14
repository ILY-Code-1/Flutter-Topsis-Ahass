import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../models/item_model.dart';
import '../../../models/barang_masuk_model.dart';
import '../../../models/barang_keluar_model.dart';

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

      // Fetch current month and year
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Fetch barang masuk data (current month)
      final barangMasukSnapshot = await _firestore
          .collection('barang_masuk')
          .where(
            'tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
          )
          .where(
            'tanggal',
            isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth),
          )
          .get();

      frekuensiBarangMasuk.value = barangMasukSnapshot.docs.length;
      int masukCount = 0;
      for (var doc in barangMasukSnapshot.docs) {
        final data = BarangMasukModel.fromMap(doc.data());
        masukCount += data.jumlah;
      }
      totalBarangMasuk.value = masukCount;

      // Fetch barang keluar data (current month)
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

      frekuensiBarangKeluar.value = barangKeluarSnapshot.docs.length;
      int keluarCount = 0;
      for (var doc in barangKeluarSnapshot.docs) {
        final data = BarangKeluarModel.fromMap(doc.data());
        keluarCount += data.jumlah;
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
