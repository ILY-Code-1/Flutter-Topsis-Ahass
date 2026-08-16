import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/barang_masuk_model.dart';
import '../models/item_model.dart';

class BarangMasukService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'barang_masuk';
  static const String _itemsCollection = 'items';

  /// Fetch all barang masuk records ordered by tanggal descending
  Future<List<BarangMasukModel>> getBarangMasuk() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('tanggal', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return BarangMasukModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Gagal memuat data barang masuk: $e');
    }
  }

  /// Fetch barang masuk records filtered by month name (Indonesian)
  Future<List<BarangMasukModel>> getBarangMasukByMonth(String month) async {
    try {
      final all = await getBarangMasuk();
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
      throw Exception('Gagal memfilter data barang masuk: $e');
    }
  }

  /// Add new barang masuk records and increment stok_sekarang in items.
  /// All records are written atomically in a single Firestore batch.
  Future<void> addBarangMasuk(List<BarangMasukModel> records) async {
    try {
      if (records.isEmpty) {
        throw Exception('Tidak ada barang masuk untuk dicatat');
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

      final batch = _firestore.batch();

      for (final record in records) {
        final masukRef = _firestore.collection(_collection).doc();
        batch.set(masukRef, record.toMap());

        final itemDoc = itemDocs[record.idBarang]!;
        final data = itemDoc.data();
        final currentStok = (data['stok_sekarang'] as num).toInt();
        final stokMinimum = (data['stok_minimum'] as num).toInt();
        final newStok = currentStok + record.jumlah;
        final newStatus = ItemModel.calculateStatusStok(newStok, stokMinimum);

        batch.update(itemDoc.reference, {
          'stok_sekarang': newStok,
          'status_stok': newStatus,
          'last_update': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal menambah barang masuk: $e');
    }
  }
}
