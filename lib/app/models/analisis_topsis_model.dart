import 'package:cloud_firestore/cloud_firestore.dart';

class AnalisisTopsisModel {
  final String? analysisId;
  final int periodeBulan;
  final int periodeTahun;
  final Timestamp createdAt;
  final int totalItems;
  final List<Map<String, dynamic>> criteria;
  final List<Map<String, dynamic>> results;

  AnalisisTopsisModel({
    this.analysisId,
    required this.periodeBulan,
    required this.periodeTahun,
    required this.createdAt,
    required this.totalItems,
    required this.criteria,
    required this.results,
  });

  factory AnalisisTopsisModel.fromMap(
    Map<String, dynamic> map,
    String analysisId,
  ) {
    return AnalisisTopsisModel(
      analysisId: analysisId,
      periodeBulan: (map['periode_bulan'] as num?)?.toInt() ?? 0,
      periodeTahun: (map['periode_tahun'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] as Timestamp? ?? Timestamp.now(),
      totalItems: (map['total_items'] as num?)?.toInt() ?? 0,
      criteria: List<Map<String, dynamic>>.from(
        (map['criteria'] as List<dynamic>?) ?? [],
      ),
      results: List<Map<String, dynamic>>.from(
        (map['results'] as List<dynamic>?) ?? [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'periode_bulan': periodeBulan,
      'periode_tahun': periodeTahun,
      'created_at': createdAt,
      'total_items': totalItems,
      'criteria': criteria,
      'results': results,
    };
  }
}
