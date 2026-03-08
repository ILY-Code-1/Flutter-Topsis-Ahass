import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../core/core.dart';
import '../../../services/auth_service.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/admin_drawer.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      drawer: const AdminDrawer(currentRoute: '/admin-dashboard'),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.hondaRed,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Admin ${authService.username}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Text(
              'Selamat datang di dashboard',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
            tooltip: 'Notifikasi',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: controller.refreshDashboard,
            tooltip: 'Refresh Data',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.hondaRed,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Memuat data...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                // padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildWelcomeSection(context),
                          const SizedBox(height: 32),

                          // Stats Cards
                          Responsive.isMobile(context)
                              ? _buildMobileLayout()
                              : _buildDesktopLayout(),

                          const SizedBox(height: 32),

                          // Quick Actions
                          _buildQuickActions(context),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Footer
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.hondaRed, AppColors.hondaRedDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.hondaRed.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AHASS AutoPart Monitor',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistem monitoring dan analisis stok berbasis TOPSIS',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/logo.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildStatCard(
          title: 'Total Item',
          description: 'Total variasi sparepart terdaftar',
          value: controller.totalItems.value.toString(),
          icon: Icons.inventory_2_rounded,
          color: AppColors.hondaRed,
          delay: 0,
        ),
        const SizedBox(height: 16),
        _buildTransactionCard(
          title: 'Barang Masuk',
          icon: Icons.add_business_rounded,
          color: AppColors.success,
          delay: 150,
          frekuensi: controller.frekuensiBarangMasuk.value,
          totalQty: controller.totalBarangMasuk.value,
        ),
        const SizedBox(height: 16),
        _buildTransactionCard(
          title: 'Barang Keluar',
          icon: Icons.move_to_inbox_rounded,
          color: AppColors.warning,
          delay: 300,
          frekuensi: controller.frekuensiBarangKeluar.value,
          totalQty: controller.totalBarangKeluar.value,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Item',
            description: 'Total variasi sparepart terdaftar',
            value: controller.totalItems.value.toString(),
            icon: Icons.inventory_2_rounded,
            color: AppColors.hondaRed,
            delay: 0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTransactionCard(
            title: 'Barang Masuk',
            icon: Icons.add_business_rounded,
            color: AppColors.success,
            delay: 150,
            frekuensi: controller.frekuensiBarangMasuk.value,
            totalQty: controller.totalBarangMasuk.value,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTransactionCard(
            title: 'Barang Keluar',
            icon: Icons.move_to_inbox_rounded,
            color: AppColors.warning,
            delay: 300,
            frekuensi: controller.frekuensiBarangKeluar.value,
            totalQty: controller.totalBarangKeluar.value,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required IconData icon,
    required Color color,
    required int delay,
    required int frekuensi,
    required int totalQty,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: color,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              totalQty.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 12,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  '$frekuensi transaksi',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String description,
    required String value,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: color,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.hondaRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.play_circle_rounded,
                    color: AppColors.hondaRed,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Aksi Cepat',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Responsive.isMobile(context)
                ? Column(
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.inventory_2_rounded,
                        title: 'Kelola Stock',
                        subtitle: 'Kelola daftar sparepart',
                        color: AppColors.hondaRed,
                        onTap: () => Get.toNamed('/item-management'),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionButton(
                        icon: Icons.people_rounded,
                        title: 'Kelola User',
                        subtitle: 'Kelola akun staff dan admin',
                        color: AppColors.primary,
                        onTap: controller.navigateToUserManagement,
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionButton(
                        icon: Icons.history_rounded,
                        title: 'Lihat Riwayat',
                        subtitle: 'Semua perhitungan TOPSIS',
                        color: AppColors.success,
                        onTap: controller.navigateToHistory,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.inventory_2_rounded,
                          title: 'Kelola Stock',
                          subtitle: 'Kelola daftar sparepart',
                          color: AppColors.hondaRed,
                          onTap: () => Get.toNamed('/item-management'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.people_rounded,
                          title: 'Kelola User',
                          subtitle: 'Kelola akun staff dan admin',
                          color: AppColors.primary,
                          onTap: controller.navigateToUserManagement,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.history_rounded,
                          title: 'Lihat Riwayat',
                          subtitle: 'Semua perhitungan TOPSIS',
                          color: AppColors.success,
                          onTap: controller.navigateToHistory,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(color: AppColors.hondaRed),
      child: const Center(
        child: Text(
          '© Copyright AHASS AutoPart Monitor, 2026',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
