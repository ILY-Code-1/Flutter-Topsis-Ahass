import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/stock_table_widget.dart';
import '../controllers/staff_stock_controller.dart';
import '../../staff_dashboard/widgets/staff_drawer.dart';

class StaffStockView extends GetView<StaffStockController> {
  const StaffStockView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      drawer: const StaffDrawer(currentRoute: '/staff-stock'),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.hondaRed,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Staff ${authService.username}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Text(
              'KELOLA STOCK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
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
            onPressed: () {
              controller.fetchItems();
              controller.fetchTransactions();
            },
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.softPink.withOpacity(0.3),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value && controller.displayItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.displayItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.hondaRed.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: AppColors.hondaRed.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Tidak ada data untuk bulan ini',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.selectedMonth.value.isEmpty
                        ? 'Pilih bulan untuk melihat transaksi'
                        : 'Tidak ada transaksi pada bulan ${controller.selectedMonth.value}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Card
                        _buildHeaderCard(context),
                        const SizedBox(height: 16),
                        // Stock Table
                        StockTableWidget(
                          items: controller.displayItems,
                          config: StockTableConfig(
                            showActions: false,
                            isEditable: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Footer
              _buildFooter(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Stock',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.hondaRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 16,
                              color: AppColors.hondaRed,
                            ),
                            const SizedBox(width: 6),
                            Obx(() => Text(
                              'Total: ${controller.displayItems.length} item',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.hondaRed,
                                fontWeight: FontWeight.w600,
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Month Filter Dropdown
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: Obx(() => DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Pilih Bulan'),
                          value: controller.selectedMonth.value.isNotEmpty
                              ? controller.selectedMonth.value
                              : null,
                          items: const [
                            DropdownMenuItem(
                              value: 'Semua',
                              child: Text('Semua Bulan'),
                            ),
                            DropdownMenuItem(
                              value: 'Januari',
                              child: Text('Januari'),
                            ),
                            DropdownMenuItem(
                              value: 'Februari',
                              child: Text('Februari'),
                            ),
                            DropdownMenuItem(
                              value: 'Maret',
                              child: Text('Maret'),
                            ),
                            DropdownMenuItem(
                              value: 'April',
                              child: Text('April'),
                            ),
                            DropdownMenuItem(
                              value: 'Mei',
                              child: Text('Mei'),
                            ),
                            DropdownMenuItem(
                              value: 'Juni',
                              child: Text('Juni'),
                            ),
                            DropdownMenuItem(
                              value: 'Juli',
                              child: Text('Juli'),
                            ),
                            DropdownMenuItem(
                              value: 'Agustus',
                              child: Text('Agustus'),
                            ),
                            DropdownMenuItem(
                              value: 'September',
                              child: Text('September'),
                            ),
                            DropdownMenuItem(
                              value: 'Oktober',
                              child: Text('Oktober'),
                            ),
                            DropdownMenuItem(
                              value: 'November',
                              child: Text('November'),
                            ),
                            DropdownMenuItem(
                              value: 'Desember',
                              child: Text('Desember'),
                            ),
                          ],
                          onChanged: (value) {
                            controller.selectedMonth.value = value ?? '';
                            controller.applyMonthFilter();
                          },
                        )),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.hondaRed,
      child: const Center(
        child: Text(
          '© 2026 AHASS AutoPart Monitor. All rights reserved.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
