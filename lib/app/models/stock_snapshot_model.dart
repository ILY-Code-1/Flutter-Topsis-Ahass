
import 'package:cloud_firestore/cloud_firestore.dart';
import 'item_model.dart';

class StockSnapshotModel {
  final String? snapshotId;
  final int bulan;
  final int tahun;
  final Timestamp createdAt;
  final List<ItemModel> items;

  StockSnapshotModel({
    this.snapshotId,
    required this.bulan,
    required this.tahun,
    required this.createdAt,
    required this.items,
  });

  factory StockSnapshotModel.fromMap(Map<String, dynamic> map, String snapshotId) {
    return StockSnapshotModel(
      snapshotId: snapshotId,
      bulan: map['bulan'] as int,
      tahun: map['tahun'] as int,
      createdAt: map['created_at'] as Timestamp,
      items: (map['items'] as List<dynamic>)
          .map((itemMap) => ItemModel.fromMap(itemMap as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bulan': bulan,
      'tahun': tahun,
      'created_at': createdAt,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}
