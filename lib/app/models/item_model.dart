import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class for item data in Firestore 'items' collection
///
/// Represents a spare part item with stock information and status.
/// The status_stok is automatically calculated based on stok values.
class ItemModel {
  final String idBarang;
  final String namaBarang;
  final String kategori;
  final int stokSekarang;
  final int stokMinimum;
  final int leadTime;
  final String statusStok;
  final Timestamp lastUpdate;

  ItemModel({
    required this.idBarang,
    required this.namaBarang,
    required this.kategori,
    required this.stokSekarang,
    required this.stokMinimum,
    required this.leadTime,
    required this.statusStok,
    required this.lastUpdate,
  });

  /// Creates ItemModel from a Firestore document snapshot
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      idBarang: map['id_barang'] as String,
      namaBarang: map['nama_barang'] as String,
      kategori: map['kategori'] as String,
      stokSekarang: (map['stok_sekarang'] as num).toInt(),
      stokMinimum: (map['stok_minimum'] as num).toInt(),
      leadTime: (map['lead_time'] as num).toInt(),
      statusStok: map['status_stok'] as String,
      lastUpdate: map['last_update'] as Timestamp,
    );
  }

  /// Converts ItemModel to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id_barang': idBarang,
      'nama_barang': namaBarang,
      'kategori': kategori,
      'stok_sekarang': stokSekarang,
      'stok_minimum': stokMinimum,
      'lead_time': leadTime,
      'status_stok': statusStok,
      'last_update': lastUpdate,
    };
  }

  /// Calculates stock status based on current stock and minimum stock
  ///
  /// Returns:
  /// - 'Aman' if stokSekarang > stokMinimum
  /// - 'Menipis' if stokSekarang == stokMinimum
  /// - 'Kritis' if stokSekarang < stokMinimum
  static String calculateStatusStok(int stokSekarang, int stokMinimum) {
    if (stokSekarang > stokMinimum) {
      return 'Aman';
    } else if (stokSekarang == stokMinimum) {
      return 'Menipis';
    } else {
      return 'Kritis';
    }
  }

  /// Creates a copy of this ItemModel with some fields replaced
  ItemModel copyWith({
    String? idBarang,
    String? namaBarang,
    String? kategori,
    int? stokSekarang,
    int? stokMinimum,
    int? leadTime,
    String? statusStok,
    Timestamp? lastUpdate,
  }) {
    return ItemModel(
      idBarang: idBarang ?? this.idBarang,
      namaBarang: namaBarang ?? this.namaBarang,
      kategori: kategori ?? this.kategori,
      stokSekarang: stokSekarang ?? this.stokSekarang,
      stokMinimum: stokMinimum ?? this.stokMinimum,
      leadTime: leadTime ?? this.leadTime,
      statusStok: statusStok ?? this.statusStok,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  String toString() {
    return 'ItemModel(idBarang: $idBarang, namaBarang: $namaBarang, kategori: $kategori, stokSekarang: $stokSekarang, stokMinimum: $stokMinimum, leadTime: $leadTime, statusStok: $statusStok, lastUpdate: $lastUpdate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemModel &&
        other.idBarang == idBarang &&
        other.namaBarang == namaBarang &&
        other.kategori == kategori &&
        other.stokSekarang == stokSekarang &&
        other.stokMinimum == stokMinimum &&
        other.leadTime == leadTime &&
        other.statusStok == statusStok &&
        other.lastUpdate == lastUpdate;
  }

  @override
  int get hashCode {
    return idBarang.hashCode ^
        namaBarang.hashCode ^
        kategori.hashCode ^
        stokSekarang.hashCode ^
        stokMinimum.hashCode ^
        leadTime.hashCode ^
        statusStok.hashCode ^
        lastUpdate.hashCode;
  }
}
