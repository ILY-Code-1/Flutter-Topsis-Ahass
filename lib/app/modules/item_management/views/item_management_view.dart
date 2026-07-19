import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../widgets/custom_input.dart';
import '../../../widgets/stock_table_widget.dart';
import '../../../models/item_model.dart';
import '../controllers/item_management_controller.dart';
import '../../admin_dashboard/widgets/admin_drawer.dart';
import '../../topsis/controllers/topsis_controller.dart';

class ItemManagementView extends GetView<ItemManagementController> {
  const ItemManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final TopsisController topsisController = Get.find<TopsisController>();
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/item-management'),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kelola Stock',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.hondaRed, AppColors.hondaRedDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.fetchItems,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.softPink.withOpacity(0.3), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Header Card with filters - ALWAYS visible
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 1400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                            'Daftar Item',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => Row(
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
                                    Text(
                                      'Total: ${controller.items.length} item',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.hondaRed,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Month Filter Dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
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
                              onChanged: controller.onMonthChanged,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Year Filter Dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              hint: const Text('Pilih Tahun'),
                              value: controller.selectedYear.value,
                              items: ItemManagementController.availableYears
                                  .map((year) {
                                return DropdownMenuItem<int>(
                                  value: year,
                                  child: Text(year.toString()),
                                );
                              }).toList(),
                              onChanged: controller.onYearChanged,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Mulai Analisis Button
                      Expanded(
                        child: Obx(
                          () => ElevatedButton.icon(
                            onPressed: topsisController.isLoading.value
                                ? null
                                : () async {
                                    int? analysisMonth;
                                    int? analysisYear;
                                    if (controller.selectedMonth.value
                                            .isNotEmpty &&
                                        controller.selectedMonth.value !=
                                            'Semua') {
                                      analysisMonth = ItemManagementController
                                          .monthMap[controller
                                              .selectedMonth.value];
                                      analysisYear =
                                          controller.selectedYear.value;
                                    }
                                    await topsisController.runAnalysis(
                                      month: analysisMonth,
                                      year: analysisYear,
                                    );
                                    controller.fetchItems();
                                  },
                            icon: topsisController.isLoading.value
                                ? Container(
                                    width: 20,
                                    height: 20,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.analytics, size: 20),
                            label: Text(
                              topsisController.isLoading.value
                                  ? 'Analyzing...'
                                  : 'Analyze Stock Priority',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Data section - conditional
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.items.isEmpty) {
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
                        Obx(() {
                          if (controller.isViewingHistorical.value &&
                              !controller.snapshotExists.value) {
                            return Column(
                              children: [
                                Text(
                                  'Tidak ada data',
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada data stock snapshot untuk ${controller.selectedMonth.value} ${controller.selectedYear.value}',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              Text(
                                'Belum ada item',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Klik tombol + untuk menambah item baru',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  );
                }

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Historical Banner
                          Obx(() {
                            if (controller.isViewingHistorical.value) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.info,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      color: AppColors.info,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Menampilkan data historis: ${controller.selectedMonth.value} ${controller.selectedYear.value}',
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.info,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                          // Table Card
                          Obx(() => StockTableWidget(
                            items: controller.items,
                            config: StockTableConfig(
                              showActions: !controller.isViewingHistorical.value,
                              isEditable: !controller.isViewingHistorical.value,
                              onRefresh: controller.fetchItems,
                              showTransactions: false,
                              onEdit: (idBarang) {
                                final item = controller.getItemById(idBarang);
                                if (item != null) {
                                  showItemFormDialog(item: item);
                                }
                              },
                              onDelete: (namaBarang, idBarang) {
                                controller.deleteItem(idBarang, namaBarang);
                              },
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.isViewingHistorical.value) {
          return const SizedBox.shrink();
        }
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.hondaRed.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => showItemFormDialog(),
            foregroundColor: Colors.white,
            elevation: 0,
            icon: const Icon(Icons.add, size: 24),
            label: const Text(
              'Tambah Item',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      }),
    );
  }

  void showItemFormDialog({ItemModel? item}) {
    if (item == null) {
      controller.resetForm();
    } else {
      controller.loadItemToForm(item);
    }

    String? _normalizeKategori(String value) {
      final v = value.trim().toLowerCase();
      const options = ['sparepart', 'electrical', 'oli'];
      return options.contains(v) ? v : null;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item == null ? 'Tambah Item Baru' : 'Edit Item',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ID Barang field
                  CustomInput(
                    label: 'ID Barang',
                    hint: 'BRG001',
                    controller: controller.idBarangController,
                    enabled: item == null, // Disabled when editing
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ID barang tidak boleh kosong';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.qr_code_outlined),
                    infoTooltip:
                        'Kode unik untuk barang (tidak bisa diubah setelah dibuat)',
                  ),
                  const SizedBox(height: 16),

                  // Nama Barang field
                  CustomInput(
                    label: 'Nama Barang',
                    hint: 'Oli Mesin 10W-30',
                    controller: controller.namaBarangController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama barang tidak boleh kosong';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    infoTooltip: 'Nama produk atau barang yang akan dikelola',
                  ),
                  const SizedBox(height: 16),

                  // Kategori field (Dropdown)
                  DropdownButtonFormField<String>(
                    initialValue: _normalizeKategori(
                      controller.kategoriController.text,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.category_outlined),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.hondaRed,
                          width: 2,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'sparepart',
                        child: Text('sparepart'),
                      ),
                      DropdownMenuItem(
                        value: 'electrical',
                        child: Text('electrical'),
                      ),
                      DropdownMenuItem(value: 'oli', child: Text('oli')),
                    ],
                    onChanged: (val) {
                      controller.kategoriController.text = val ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kategori tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Stok Minimum field
                  CustomInput(
                    label: 'Stok Minimum',
                    hint: '10',
                    controller: controller.stokMinimumController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok minimum tidak boleh kosong';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.looks_one_outlined),
                    infoTooltip: 'Batas minimum stok sebelum dianggap menipis',
                  ),
                  const SizedBox(height: 16),

                  // Stok Saat Ini field
                  CustomInput(
                    label: 'Stok Saat Ini',
                    hint: '15',
                    controller: controller.stokSekarangController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok saat ini tidak boleh kosong';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.looks_two_outlined),
                    infoTooltip: 'Jumlah stok yang tersedia sekarang (unit)',
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 8),

                  // Info note about status
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.info, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Status stok akan dihitung otomatis berdasarkan Stok Saat Ini dan Stok Minimum.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          // 1. Validasi form terlebih dahulu
                          if (controller.formKey.currentState?.validate() ??
                              false) {
                            Get.back();
                            await controller.saveItem();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Text(item == null ? 'Tambah' : 'Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

/*
 * ============================================================================
 * DOKUMENTASI PERBAIKAN UI - FILTER SELALU VISIBLE
 * ============================================================================
 * 
 * TANGGAL: Juli 2026
 * 
 * BUG (FASE 2):
 * - Saat empty state, filter dropdown hilang
 * - User tidak bisa mengubah filter setelah melihat data kosong
 * - Harus refresh halaman untuk mencoba filter lain
 * 
 * ROOT CAUSE:
 * - Struktur body menggunakan conditional Obx yang replace entire content
 * - Filter card ada di dalam section yang hanya di-render saat items tidak kosong
 * - Empty state di-render sebagai pengganti seluruh data section termasuk filter
 * 
 * STRUKTUR SEBELUM (SALAH):
 * body: Obx(() {
 *   if (loading) → loading indicator
 *   if (items.isEmpty) → empty state (TANPA FILTER) ← BUG
 *   return Column [FilterCard, Banner, Table]
 * })
 * 
 * STRUKTUR SESUDAH (BENAR):
 * body: Column [
 *   FilterCard,  ← SELALU visible
 *   Expanded(
 *     child: Obx(() {
 *       if (loading) → loading
 *       if (items.isEmpty) → empty state
 *       return Table
 *     })
 *   )
 * ]
 * 
 * PELAJARAN:
 * - UI elements yang dibutuhkan untuk interaksi user harus SELALU visible
 * - Pisahkan antara "control panel" (filter) dan "data display" (table/empty)
 * - Empty state bukan pengganti seluruh UI, hanya pengganti data display
 * - Gunakan Expanded untuk data section agar filter tetap fixed di atas
 * 
 * FITUR TAMBAHAN:
 * - Banner "Menampilkan data historis" saat filter bulan aktif
 * - Hide FAB "Tambah Item" saat viewing historical data
 * - Disable edit/delete actions di tabel saat viewing historical data
 * - Empty state berbeda untuk data historis vs data real-time
 * 
 * ============================================================================
 */
