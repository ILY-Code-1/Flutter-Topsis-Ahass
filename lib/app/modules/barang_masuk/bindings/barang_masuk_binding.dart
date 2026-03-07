import 'package:get/get.dart';
import '../controllers/barang_masuk_controller.dart';
import '../../../services/barang_masuk_service.dart';
import '../../../services/item_service.dart';

class BarangMasukBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemService>(() => ItemService());
    Get.lazyPut<BarangMasukService>(() => BarangMasukService());
    Get.lazyPut<BarangMasukController>(() => BarangMasukController());
  }
}
