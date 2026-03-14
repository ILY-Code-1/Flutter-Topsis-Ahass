import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/analisis_topsis_model.dart';
import '../models/stock_snapshot_model.dart';
import '../models/item_model.dart';

class TopsisService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<StockSnapshotModel?> getSnapshot(int month, int year) async {
    try {
      final query = await _firestore
          .collection('stock_snapshot')
          .where('bulan', isEqualTo: month)
          .where('tahun', isEqualTo: year)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return StockSnapshotModel.fromMap(
        query.docs.first.data(),
        query.docs.first.id,
      );
    } catch (e) {
      throw Exception('Failed to get snapshot: $e');
    }
  }

  Future<String> createSnapshot(
    List<ItemModel> items,
    int month,
    int year,
  ) async {
    try {
      final snapshot = StockSnapshotModel(
        bulan: month,
        tahun: year,
        createdAt: Timestamp.now(),
        items: items,
      );

      final docRef = await _firestore
          .collection('stock_snapshot')
          .add(snapshot.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create snapshot: $e');
    }
  }

  Future<String> saveAnalysis(AnalisisTopsisModel analysis) async {
    try {
      final docRef = await _firestore
          .collection('analisis_topsis')
          .add(analysis.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save analysis: $e');
    }
  }

  Future<List<AnalisisTopsisModel>> getAnalysisHistory() async {
    try {
      final query = await _firestore
          .collection('analisis_topsis')
          .orderBy('created_at', descending: true)
          .get();

      return query.docs
          .map((doc) => AnalisisTopsisModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get analysis history: $e');
    }
  }

  Future<AnalisisTopsisModel> getAnalysisDetail(String analysisId) async {
    try {
      final doc = await _firestore
          .collection('analisis_topsis')
          .doc(analysisId)
          .get();
      return AnalisisTopsisModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get analysis detail: $e');
    }
  }

  Future<void> deleteAnalysis(String analysisId) async {
    try {
      await _firestore.collection('analisis_topsis').doc(analysisId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus riwayat analisis: $e');
    }
  }
}
