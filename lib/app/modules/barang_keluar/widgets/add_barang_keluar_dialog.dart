import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

class _KeluarRow {
  ItemModel? item;
  final TextEditingController jumlahController = TextEditingController();
}

class _AddBarangKeluarDialogState extends State<AddBarangKeluarDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<_KeluarRow> _rows = [_KeluarRow()];

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    for (final row in _rows) {
      row.jumlahController.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() => _rows.add(_KeluarRow()));
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows[index].jumlahController.dispose();
      _rows.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BarangKeluarController>();
    final authService = Get.find<AuthService>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  const Text(
                    'Daftar Barang Keluar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  for (int i = 0; i < _rows.length; i++) _buildRow(i, controller),

                  Obx(() {
                    final canAdd = controller.items.length > _rows.length;
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: canAdd ? _addRow : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(
                            color: canAdd ? AppColors.error : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text(
                          'Tambah Barang',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  const Text(
                    'Tanggal & Waktu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = DateTime(
                                picked.year, picked.month, picked.day,
                                _selectedTime.hour, _selectedTime.minute,
                              ));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd MMM yyyy').format(_selectedDate),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedTime = picked;
                                _selectedDate = DateTime(
                                  _selectedDate.year, _selectedDate.month, _selectedDate.day,
                                  picked.hour, picked.minute,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime.format(context),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

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
      ),
    );
  }

  Widget _buildRow(int index, BarangKeluarController controller) {
    final row = _rows[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Barang ${index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _rows.length > 1 ? () => _removeRow(index) : null,
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: _rows.length > 1
                      ? AppColors.error
                      : AppColors.textHint,
                ),
                tooltip: 'Hapus baris',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final selectedIds = _rows
                .map((r) => r.item?.idBarang)
                .whereType<String>()
                .toSet();
            final availableItems = controller.items
                .where((item) =>
                    !selectedIds.contains(item.idBarang) ||
                    item.idBarang == row.item?.idBarang)
                .toList();

            return DropdownButtonFormField<ItemModel>(
              initialValue: row.item,
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
              items: availableItems.map((item) {
                return DropdownMenuItem<ItemModel>(
                  value: item,
                  child: Text(
                    '${item.idBarang} - ${item.namaBarang}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => row.item = value);
              },
              validator: (value) =>
                  value == null ? 'Pilih barang terlebih dahulu' : null,
            );
          }),
          const SizedBox(height: 12),
          TextFormField(
            controller: row.jumlahController,
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
              labelText: 'Jumlah Keluar',
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
              if (row.item != null && jumlah > row.item!.stokSekarang) {
                return 'Jumlah melebihi stok saat ini (${row.item!.stokSekarang})';
              }
              return null;
            },
          ),
          if (row.item != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: AppColors.hondaRed),
                  const SizedBox(width: 6),
                  Text(
                    'Stok saat ini: ${row.item!.stokSekarang} pcs',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.hondaRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _submit(BarangKeluarController controller, AuthService authService) {
    if (!_formKey.currentState!.validate()) return;

    final records = _rows
        .map(
          (row) => BarangKeluarModel(
            tanggal: Timestamp.fromDate(_selectedDate),
            idBarang: row.item!.idBarang,
            namaBarang: row.item!.namaBarang,
            jumlah: int.parse(row.jumlahController.text.trim()),
            inputOleh: authService.username,
          ),
        )
        .toList();

    Get.back();
    controller.addBarangKeluar(records);
  }
}
