import 'package:get/get.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/topsis/bindings/topsis_binding.dart';
import '../modules/topsis/views/topsis_view.dart';
import '../modules/topsis/views/topsis_detail_view.dart';
import '../modules/form/bindings/form_binding.dart';
import '../modules/form/views/form_view.dart';
import '../modules/success/views/success_view.dart';
import '../modules/guide/bindings/guide_binding.dart';
import '../modules/guide/views/guide_view.dart';
import '../modules/user_management/bindings/user_management_binding.dart';
import '../modules/user_management/views/user_management_view.dart';
import '../modules/item_management/bindings/item_management_binding.dart';
import '../modules/item_management/views/item_management_view.dart';
import '../modules/quick_calc/bindings/quick_calc_binding.dart';
import '../modules/quick_calc/views/quick_calc_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/admin_dashboard/bindings/admin_dashboard_binding.dart';
import '../modules/admin_dashboard/views/admin_dashboard_view.dart';
import '../modules/staff_dashboard/bindings/staff_dashboard_binding.dart';
import '../modules/staff_dashboard/views/staff_dashboard_view.dart';
import '../modules/staff_stock/bindings/staff_stock_binding.dart';
import '../modules/staff_stock/views/staff_stock_view.dart';
import '../modules/barang_masuk/bindings/barang_masuk_binding.dart';
import '../modules/barang_masuk/views/barang_masuk_page.dart';
import '../modules/barang_keluar/bindings/barang_keluar_binding.dart';
import '../modules/barang_keluar/views/barang_keluar_page.dart';
import '../middlewares/auth_middleware.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const StaffDashboardView(),
      binding: StaffDashboardBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.topsis,
      page: () => const TopsisView(),
      binding: TopsisBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.topsisDetail,
      page: () => TopsisDetailView(),
      binding: TopsisBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.form,
      page: () => const FormView(),
      binding: FormBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.success,
      page: () => const SuccessView(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 400),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.guide,
      page: () => const GuideView(),
      binding: GuideBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.userManagement,
      page: () => const UserManagementView(),
      binding: UserManagementBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.itemManagement,
      page: () => const ItemManagementView(),
      binding: ItemManagementBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.adminStock,
      page: () => const ItemManagementView(),
      binding: ItemManagementBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.quickCalc,
      page: () => const QuickCalcView(),
      binding: QuickCalcBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.history,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.staffDashboard,
      page: () => const StaffDashboardView(),
      binding: StaffDashboardBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.staffStock,
      page: () => const StaffStockView(),
      binding: StaffStockBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.barangMasuk,
      page: () => const BarangMasukPage(),
      binding: BarangMasukBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.barangKeluar,
      page: () => const BarangKeluarPage(),
      binding: BarangKeluarBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
