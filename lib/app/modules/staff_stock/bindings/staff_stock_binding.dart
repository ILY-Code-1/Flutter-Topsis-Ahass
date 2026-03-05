import 'package:get/get.dart';
import '../controllers/staff_stock_controller.dart';
import '../../../services/item_service.dart';

class StaffStockBinding extends Bindings {
  @override
  void dependencies() {
    // Register ItemService (reused from Admin module)
    Get.lazyPut<ItemService>(() => ItemService());
    // Register StaffStockController
    Get.lazyPut<StaffStockController>(() => StaffStockController());
  }
}
