import 'package:get/get.dart';
import '../controllers/item_management_controller.dart';
import '../../../services/item_service.dart';

class ItemManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemService>(() => ItemService());
    Get.lazyPut<ItemManagementController>(() => ItemManagementController());
  }
}
