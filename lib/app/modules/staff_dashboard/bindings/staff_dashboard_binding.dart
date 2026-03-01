import 'package:get/get.dart';
import '../controllers/staff_dashboard_controller.dart';

class StaffDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StaffDashboardController());
  }
}
