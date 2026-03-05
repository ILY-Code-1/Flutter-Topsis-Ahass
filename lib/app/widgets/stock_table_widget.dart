import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

/// Configuration for StockTableWidget behavior
///
/// Allows customization of table for different user roles
class StockTableConfig {
  final bool showActions;
  final bool isEditable;
  final VoidCallback? onRefresh;
  final bool showTransactions;
  final String Function(String idBarang)? getMasukCount;
  final String Function(String idBarang)? getKeluarCount;

  const StockTableConfig({
    this.showActions = true,
    this.isEditable = false,
    this.onRefresh,
    this.showTransactions = false,
    this.getMasukCount,
    this.getKeluarCount,
  });
}

/// Reusable Stock Table Widget
///
/// Displays item stock information in a table or card format.
/// Can be configured for Admin (editable) or Staff (read-only) modes.
class StockTableWidget extends StatelessWidget {
  final List<ItemModel> items;
  final StockTableConfig config;
  final String selectedMonth;

  const StockTableWidget({
    super.key,
    required this.items,
    required this.config,
    this.selectedMonth = '',
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1200;

    if (isMobile) {
      return _buildMobileCards(context);
    } else {
      return _buildDataTable(context);
    }
  }

  Widget _buildDataTable(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 48,
          ),
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 24,
            headingRowHeight: 60,
            dataRowMinHeight: 70,
            dataRowMaxHeight: 80,
            headingRowColor: WidgetStateProperty.all(
              const Color(0xFF134E8E).withOpacity(0.08),
            ),
            columns: _buildTableColumns(),
            rows: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return DataRow(
                color: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (index.isEven) {
                      return const Color(0xFFE8F0F8).withOpacity(0.3);
                    }
                    return Colors.white;
                  }
                ),
                cells: [
                  _buildDataCell(item.idBarang),
                  _buildDataCell(item.namaBarang),
                  _buildDataCell(item.stokMinimum.toString()),
                  _buildDataCell(item.stokSekarang.toString()),
                  _buildDataCell('${item.leadTime} hari'),
                  _buildDataCell(_formatTimestamp(item.lastUpdate)),
                  _buildStatusCell(item.statusStok),
                  if (config.showActions)
                    _buildActionCell(item.namaBarang, item.idBarang)
                  else
                    _buildReadOnlyIndicator(),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCards(BuildContext context) {
    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, const Color(0xFFE8F0F8).withOpacity(0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE21F26).withOpacity(0.05),
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
                              const Color(0xFF134E8E).withOpacity(0.2),
                              const Color(0xFF134E8E).withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inventory_2,
                          color: const Color(0xFFE21F26),
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${item.idBarang}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF718096),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kategori: ${item.kategori}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF718096),
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (config.showActions)
                    _buildActionButtons(item.namaBarang, item.idBarang),
                  if (!config.showActions)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildReadOnlyIndicatorCard(),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<DataColumn> _buildTableColumns() {
    List<DataColumn> columns = [
      _buildDataColumn('Id Barang', Icons.qr_code_outlined),
      _buildDataColumn('Nama Barang', Icons.inventory_2_outlined),
      _buildDataColumn('Stok Minimum', Icons.looks_one_outlined),
      _buildDataColumn('Stok Saat Ini', Icons.looks_two_outlined),
      _buildDataColumn('Lead Time (Hari)', Icons.access_time_outlined),
      _buildDataColumn('Tanggal Update', Icons.calendar_today_outlined),
      _buildDataColumn('Status Stok', Icons.info_outline),
    ];

    if (config.showActions) {
      columns.add(_buildDataColumn('Aksi', Icons.settings_outlined));
    }

    return columns;
  }

  DataColumn _buildDataColumn(String label, IconData icon) {
    return DataColumn(
      label: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE21F26)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFFE21F26),
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
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  DataCell _buildStatusCell(String statusStok) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(statusStok),
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
      ),
    );
  }

  DataCell _buildActionCell(String namaBarang, String idBarang) {
    return DataCell(
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
              onPressed: () => _editItem(idBarang),
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
              onPressed: () => _deleteItem(namaBarang, idBarang),
            ),
          ),
        ],
      ),
    );
  }

  DataCell _buildReadOnlyIndicator() {
    return const DataCell(
      Center(
        child: Icon(
          Icons.block_outlined,
          color: Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String statusStok) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(statusStok),
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

  Widget _buildActionButtons(String namaBarang, String idBarang) {
    return Row(
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
            onPressed: () => _editItem(idBarang),
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
            onPressed: () => _deleteItem(namaBarang, idBarang),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyIndicatorCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.block_outlined,
            size: 16,
            color: Colors.grey,
          ),
          SizedBox(width: 4),
          Text(
            'Read Only',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE21F26).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFE21F26)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: const Color(0xFFE21F26),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String statusStok) {
    switch (statusStok) {
      case 'Aman':
        return const Color(0xFF3DA35D);
      case 'Menipis':
        return const Color(0xFFFFB33F);
      case 'Kritis':
        return const Color(0xFFC00707);
      default:
        return Colors.grey;
    }
  }

  void _editItem(String idBarang) {
    if (config.onRefresh != null) return;
    // This will be handled by the parent page/controller
    // For now, just show a snackbar
    Get.snackbar(
      'Info',
      'Edit functionality will be implemented by parent',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _deleteItem(String namaBarang, String idBarang) {
    if (config.onRefresh != null) return;
    // This will be handled by the parent page/controller
    // For now, just show a snackbar
    Get.snackbar(
      'Info',
      'Delete functionality will be implemented by parent',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
