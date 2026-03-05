import 'package:get/get.dart';
import '../controllers/user_management_controller.dart';
import '../../../services/user_service.dart';

class UserManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserService>(() => UserService());
    Get.lazyPut<UserManagementController>(() => UserManagementController());
  }
}
