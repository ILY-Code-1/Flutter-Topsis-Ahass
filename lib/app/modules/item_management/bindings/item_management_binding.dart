
import 'package:get/get.dart';
import '../controllers/item_management_controller.dart';
import '../../../services/item_service.dart';
import '../../topsis/controllers/topsis_controller.dart';
import '../../../services/topsis_service.dart';

class ItemManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemService>(() => ItemService());
    Get.lazyPut<TopsisService>(() => TopsisService());
    Get.lazyPut<ItemManagementController>(() => ItemManagementController());
    Get.lazyPut<TopsisController>(() => TopsisController());
  }
}
