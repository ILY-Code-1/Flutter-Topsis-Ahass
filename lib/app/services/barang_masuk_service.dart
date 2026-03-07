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

  /// Add a new barang masuk record and increment stok_sekarang in items
  Future<void> addBarangMasuk(BarangMasukModel record) async {
    try {
      // Find the item document by id_barang
      final itemQuery = await _firestore
          .collection(_itemsCollection)
          .where('id_barang', isEqualTo: record.idBarang)
          .limit(1)
          .get();

      if (itemQuery.docs.isEmpty) {
        throw Exception('Barang dengan kode ${record.idBarang} tidak ditemukan');
      }

      final itemDoc = itemQuery.docs.first;
      final currentData = itemDoc.data();
      final currentStok = (currentData['stok_sekarang'] as num).toInt();
      final stokMinimum = (currentData['stok_minimum'] as num).toInt();
      final newStok = currentStok + record.jumlah;
      final newStatus = ItemModel.calculateStatusStok(newStok, stokMinimum);

      // Run as batch for atomicity
      final batch = _firestore.batch();

      // Add barang_masuk document
      final masukRef = _firestore.collection(_collection).doc();
      batch.set(masukRef, record.toMap());

      // Update items stok_sekarang and last_update
      batch.update(itemDoc.reference, {
        'stok_sekarang': newStok,
        'status_stok': newStatus,
        'last_update': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal menambah barang masuk: $e');
    }
  }
}
