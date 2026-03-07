import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../services/auth_service.dart';
import '../../staff_dashboard/widgets/staff_drawer.dart';
import '../controllers/barang_keluar_controller.dart';
import '../widgets/add_barang_keluar_dialog.dart';

class BarangKeluarPage extends GetView<BarangKeluarController> {
  const BarangKeluarPage({super.key});

  static const List<String> _months = [
    'Semua', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      drawer: const StaffDrawer(currentRoute: '/barang-keluar'),
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
              'BARANG KELUAR',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: controller.fetchAll,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.softPink.withValues(alpha: 0.3),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeaderCard(context),
                        const SizedBox(height: 16),
                        _buildTable(context),
                      ],
                    ),
                  ),
                ),
              ),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                    'Daftar Barang Keluar',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.move_to_inbox_rounded,
                                size: 16, color: AppColors.error),
                            const SizedBox(width: 6),
                            Text(
                              'Total: ${controller.displayRecords.length} transaksi',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
              // Add button
              ElevatedButton.icon(
                onPressed: () => Get.dialog(const AddBarangKeluarDialog()),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  '+ BARANG KELUAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Month Filter
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
                          items: _months
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m),
                                  ))
                              .toList(),
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

  Widget _buildTable(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Obx(() {
      if (controller.displayRecords.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.move_to_inbox_outlined,
                    size: 64,
                    color: AppColors.hondaRed.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(
                  'Belum ada data barang keluar',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tekan tombol + BARANG KELUAR untuk mencatat transaksi',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (isMobile) {
        return _buildMobileCards();
      }
      return _buildDesktopTable(context);
    });
  }

  Widget _buildDesktopTable(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 48,
          ),
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 24,
            headingRowHeight: 56,
            dataRowMinHeight: 60,
            dataRowMaxHeight: 70,
            headingRowColor: WidgetStateProperty.all(
              AppColors.error.withValues(alpha: 0.08),
            ),
            columns: const [
              DataColumn(label: _TableHeader(label: 'Tanggal Keluar', icon: Icons.calendar_today_outlined)),
              DataColumn(label: _TableHeader(label: 'Kode Barang', icon: Icons.qr_code_outlined)),
              DataColumn(label: _TableHeader(label: 'Nama Barang', icon: Icons.inventory_2_outlined)),
              DataColumn(label: _TableHeader(label: 'Jumlah Keluar', icon: Icons.remove_circle_outline)),
              DataColumn(label: _TableHeader(label: 'Input Oleh', icon: Icons.person_outline)),
            ],
            rows: controller.displayRecords.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              final date = record.tanggal.toDate();
              return DataRow(
                color: WidgetStateProperty.resolveWith<Color>(
                  (states) => index.isEven
                      ? AppColors.softPink.withValues(alpha: 0.2)
                      : Colors.white,
                ),
                cells: [
                  DataCell(Text(controller.formatDate(date), style: _cellStyle)),
                  DataCell(Text(record.idBarang, style: _cellStyle)),
                  DataCell(Text(record.namaBarang, style: _cellStyle)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-${record.jumlah}',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(record.inputOleh, style: _cellStyle)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCards() {
    return Column(
      children: controller.displayRecords.map((record) {
        final date = record.tanggal.toDate();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
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
                  Text(record.namaBarang,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      )),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '-${record.jumlah}',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Kode: ${record.idBarang}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('Tanggal: ${controller.formatDate(date)}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('Input oleh: ${record.inputOleh}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        );
      }).toList(),
    );
  }

  static const TextStyle _cellStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.textPrimary,
  );

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

class _TableHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TableHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.error),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}
