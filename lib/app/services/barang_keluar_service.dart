import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/barang_keluar_model.dart';
import '../models/item_model.dart';

class BarangKeluarService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'barang_keluar';
  static const String _itemsCollection = 'items';

  /// Fetch all barang keluar records ordered by tanggal descending
  Future<List<BarangKeluarModel>> getBarangKeluar() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('tanggal', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return BarangKeluarModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Gagal memuat data barang keluar: $e');
    }
  }

  /// Fetch barang keluar records filtered by month name (Indonesian)
  Future<List<BarangKeluarModel>> getBarangKeluarByMonth(String month) async {
    try {
      final all = await getBarangKeluar();
      if (month.isEmpty || month == 'Semua') return all;

      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final monthIndex = months.indexOf(month);
      if (monthIndex == -1) return all;

      return all.where((item) {
        final date = item.tanggal.toDate();
        return date.month == monthIndex + 1;
      }).toList();
    } catch (e) {
      throw Exception('Gagal memfilter data barang keluar: $e');
    }
  }

  /// Add new barang keluar records and decrement stok_sekarang in items.
  /// All records are written atomically in a single Firestore batch:
  /// if any item has insufficient stock, the whole input is rejected.
  Future<void> addBarangKeluar(List<BarangKeluarModel> records) async {
    try {
      if (records.isEmpty) {
        throw Exception('Tidak ada barang keluar untuk dicatat');
      }

      final idBarangList = records.map((r) => r.idBarang).toSet().toList();

      if (idBarangList.length != records.length) {
        throw Exception('Terdapat barang duplikat dalam satu input');
      }

      final itemQuery = await _firestore
          .collection(_itemsCollection)
          .where('id_barang', whereIn: idBarangList)
          .get();

      final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> itemDocs =
          {};
      for (final doc in itemQuery.docs) {
        itemDocs[doc.data()['id_barang'] as String] = doc;
      }

      final missingIds = idBarangList
          .where((id) => !itemDocs.containsKey(id))
          .toList();
      if (missingIds.isNotEmpty) {
        throw Exception(
          'Barang dengan kode ${missingIds.join(', ')} tidak ditemukan',
        );
      }

      final List<String> stockErrors = [];
      for (final record in records) {
        final data = itemDocs[record.idBarang]!.data();
        final currentStok = (data['stok_sekarang'] as num).toInt();
        if (record.jumlah > currentStok) {
          stockErrors.add(
            '${record.namaBarang} (jumlah ${record.jumlah} melebihi stok $currentStok)',
          );
        }
      }

      if (stockErrors.isNotEmpty) {
        throw Exception('Stok tidak mencukupi: ${stockErrors.join('; ')}');
      }

      final batch = _firestore.batch();

      for (final record in records) {
        final keluarRef = _firestore.collection(_collection).doc();
        batch.set(keluarRef, record.toMap());

        final itemDoc = itemDocs[record.idBarang]!;
        final data = itemDoc.data();
        final currentStok = (data['stok_sekarang'] as num).toInt();
        final stokMinimum = (data['stok_minimum'] as num).toInt();
        final newStok = currentStok - record.jumlah;
        final newStatus = ItemModel.calculateStatusStok(newStok, stokMinimum);

        batch.update(itemDoc.reference, {
          'stok_sekarang': newStok,
          'status_stok': newStatus,
          'last_update': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal menambah barang keluar: $e');
    }
  }
}
