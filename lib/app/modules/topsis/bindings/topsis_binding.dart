import 'package:get/get.dart';
import '../controllers/topsis_controller.dart';

class TopsisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TopsisController>(() => TopsisController());
  }
}
