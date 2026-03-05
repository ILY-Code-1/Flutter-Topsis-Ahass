import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../widgets/custom_input.dart';
import '../../../widgets/stock_table_widget.dart';
import '../../../models/item_model.dart';
import '../controllers/item_management_controller.dart';
import '../../admin_dashboard/widgets/admin_drawer.dart';

class ItemManagementView extends GetView<ItemManagementController> {
  const ItemManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/item-management'),
      appBar: AppBar(
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
            colors: [
              AppColors.softPink.withOpacity(0.3),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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
              ),
            );
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
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
                                            Text(
                                              'Total: ${controller.items.length} item',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                    color: AppColors.hondaRed,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
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
                                      onChanged: (value) {
                                        // Month filter will be implemented in future
                                        controller.selectedMonth.value = value ?? '';
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Mulai Analisis Button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to TOPSIS analysis
                                    Get.toNamed('/topsis');
                                  },
                                  icon: const Icon(Icons.analytics, size: 20),
                                  label: const Text(
                                    'Mulai Analisis',
                                    style: TextStyle(fontWeight: FontWeight.bold),
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
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Table Card
                    StockTableWidget(
                      items: controller.items,
                      config: StockTableConfig(
                        showActions: true,
                        isEditable: true,
                        onRefresh: controller.fetchItems,
                        showTransactions: false, // Admin doesn't need transaction counts
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      floatingActionButton: Container(
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
      ),
    );
  }

  Widget _buildItemTable(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1200;

    if (isMobile) {
      return _buildItemCards();
    } else {
      return _buildDataTable();
    }
  }

  Widget _buildItemCards() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: controller.items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, AppColors.softBlue.withOpacity(0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.hondaRed.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.primary.withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inventory_2,
                          color: AppColors.hondaRed,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaBarang,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${item.idBarang}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kategori: ${item.kategori}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(item.statusStok),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        'Stok Min: ${item.stokMinimum}',
                        Icons.looks_one_outlined,
                      ),
                      _buildInfoChip(
                        'Stok Saat Ini: ${item.stokSekarang}',
                        Icons.looks_two_outlined,
                      ),
                      _buildInfoChip(
                        'Lead Time: ${item.leadTime} hari',
                        Icons.access_time_outlined,
                      ),
                      _buildInfoChip(
                        'Total Keluar: TBD',
                        Icons.output,
                      ),
                      _buildInfoChip(
                        'Frekuensi: TBD',
                        Icons.update,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.formatDate(item.lastUpdate),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              color: Colors.blue.shade700,
                              onPressed: () => showItemFormDialog(item: item),
                              tooltip: 'Edit',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red.shade700,
                              onPressed: () => controller.deleteItem(
                                item.idBarang,
                                item.namaBarang,
                              ),
                              tooltip: 'Hapus',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String statusStok) {
    Color bgColor;

    switch (statusStok) {
      case 'Aman':
        bgColor = AppColors.success;
        break;
      case 'Menipis':
        bgColor = AppColors.warning;
        break;
      case 'Kritis':
        bgColor = AppColors.error;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusStok,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.hondaRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.hondaRed),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.hondaRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(Get.context!).size.width - 48,
          ),
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 24,
            headingRowHeight: 60,
            dataRowMinHeight: 70,
            dataRowMaxHeight: 80,
            headingRowColor: WidgetStateProperty.all(
              AppColors.primary.withOpacity(0.08),
            ),
            columns: [
              _buildDataColumn('Id Barang', Icons.qr_code_outlined),
              _buildDataColumn('Nama Barang', Icons.inventory_2_outlined),
              _buildDataColumn('Stok Minimum', Icons.looks_one_outlined),
              _buildDataColumn('Stok Saat Ini', Icons.looks_two_outlined),
              _buildDataColumn('Lead Time (Hari)', Icons.access_time_outlined),
              _buildDataColumn('Total Keluar', Icons.output_outlined),
              _buildDataColumn('Frekuensi Keluar', Icons.update_outlined),
              _buildDataColumn('Tanggal Update', Icons.calendar_today_outlined),
              _buildDataColumn('Status Stok', Icons.info_outline),
              _buildDataColumn('Aksi', Icons.settings_outlined),
            ],
            rows: controller.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return DataRow(
                color: WidgetStateProperty.resolveWith<Color>((
                  Set<WidgetState> states,
                ) {
                  if (index.isEven) {
                    return AppColors.softBlue.withOpacity(0.3);
                  }
                  return Colors.white;
                }),
                cells: [
                  _buildDataCell(item.idBarang),
                  _buildDataCell(item.namaBarang),
                  _buildDataCell(item.stokMinimum.toString()),
                  _buildDataCell(item.stokSekarang.toString()),
                  _buildDataCell('${item.leadTime} hari'),
                  _buildDataCell('TBD'), // To be implemented
                  _buildDataCell('TBD'), // To be implemented
                  _buildDataCell(controller.formatDate(item.lastUpdate)),
                  _buildStatusCell(item.statusStok),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: Colors.blue.shade700,
                            tooltip: 'Edit',
                            onPressed: () => showItemFormDialog(item: item),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red.shade700,
                            tooltip: 'Hapus',
                            onPressed: () => controller.deleteItem(
                              item.idBarang,
                              item.namaBarang,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  DataCell _buildStatusCell(String statusStok) {
    Color bgColor;
    Color textColor = Colors.white;

    switch (statusStok) {
      case 'Aman':
        bgColor = AppColors.success;
        break;
      case 'Menipis':
        bgColor = AppColors.warning;
        break;
      case 'Kritis':
        bgColor = AppColors.error;
        break;
      default:
        bgColor = Colors.grey;
    }

    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          statusStok,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(String label, IconData icon) {
    return DataColumn(
      label: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.hondaRed),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.hondaRed,
            ),
          ),
        ],
      ),
    );
  }

  DataCell _buildDataCell(String text) {
    return DataCell(
      Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  void showItemFormDialog({ItemModel? item}) {
    if (item == null) {
      controller.resetForm();
    } else {
      controller.loadItemToForm(item);
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
                    infoTooltip: 'Kode unik untuk barang (tidak bisa diubah setelah dibuat)',
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

                  // Kategori field
                  CustomInput(
                    label: 'Kategori',
                    hint: 'Oli',
                    controller: controller.kategoriController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kategori tidak boleh kosong';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.category_outlined),
                    infoTooltip: 'Kategori barang (contoh: Oli, Sparepart, Aksesoris)',
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

                  // Lead Time field
                  CustomInput(
                    label: 'Lead Time (Hari)',
                    hint: '7',
                    controller: controller.leadTimeController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lead time tidak boleh kosong';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.access_time_outlined),
                    infoTooltip: 'Waktu yang dibutuhkan untuk restock (hari)',
                  ),
                  const SizedBox(height: 24),

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
