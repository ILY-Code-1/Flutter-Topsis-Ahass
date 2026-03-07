import 'package:get/get.dart';
import '../controllers/barang_keluar_controller.dart';
import '../../../services/barang_keluar_service.dart';
import '../../../services/item_service.dart';

class BarangKeluarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemService>(() => ItemService());
    Get.lazyPut<BarangKeluarService>(() => BarangKeluarService());
    Get.lazyPut<BarangKeluarController>(() => BarangKeluarController());
  }
}
