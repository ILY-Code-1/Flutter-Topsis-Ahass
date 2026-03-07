import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../models/barang_keluar_model.dart';
import '../../../models/item_model.dart';
import '../../../themes/themes.dart';
import '../../../services/auth_service.dart';
import '../controllers/barang_keluar_controller.dart';

class AddBarangKeluarDialog extends StatefulWidget {
  const AddBarangKeluarDialog({super.key});

  @override
  State<AddBarangKeluarDialog> createState() => _AddBarangKeluarDialogState();
}

class _AddBarangKeluarDialogState extends State<AddBarangKeluarDialog> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();

  ItemModel? _selectedItem;

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BarangKeluarController>();
    final authService = Get.find<AuthService>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.move_to_inbox_rounded,
                        color: AppColors.error,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tambah Barang Keluar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Pilih Barang Dropdown
                const Text(
                  'Pilih Barang',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final items = controller.items;
                  return DropdownButtonFormField<ItemModel>(
                    initialValue: _selectedItem,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.hondaRed),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14,
                      ),
                      hintText: 'Pilih barang...',
                    ),
                    isExpanded: true,
                    items: items.map((item) {
                      return DropdownMenuItem<ItemModel>(
                        value: item,
                        child: Text(
                          '${item.idBarang} - ${item.namaBarang}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedItem = value);
                    },
                    validator: (value) =>
                        value == null ? 'Pilih barang terlebih dahulu' : null,
                  );
                }),
                const SizedBox(height: 16),

                // Jumlah Keluar
                const Text(
                  'Jumlah Keluar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.hondaRed),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14,
                    ),
                    hintText: 'Masukkan jumlah...',
                    suffixText: 'pcs',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah tidak boleh kosong';
                    }
                    final jumlah = int.tryParse(value);
                    if (jumlah == null || jumlah <= 0) {
                      return 'Jumlah harus lebih dari 0';
                    }
                    if (_selectedItem != null &&
                        jumlah > _selectedItem!.stokSekarang) {
                      return 'Jumlah melebihi stok saat ini (${_selectedItem!.stokSekarang})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Stock info
                if (_selectedItem != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softPink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: AppColors.hondaRed),
                        const SizedBox(width: 8),
                        Text(
                          'Stok saat ini: ${_selectedItem!.stokSekarang} pcs',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.hondaRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : () => _submit(controller, authService),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Simpan',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BarangKeluarController controller, AuthService authService) {
    if (!_formKey.currentState!.validate()) return;

    final record = BarangKeluarModel(
      tanggal: Timestamp.now(),
      idBarang: _selectedItem!.idBarang,
      namaBarang: _selectedItem!.namaBarang,
      jumlah: int.parse(_jumlahController.text.trim()),
      inputOleh: authService.username,
    );

    Get.back();
    controller.addBarangKeluar(record);
  }
}
