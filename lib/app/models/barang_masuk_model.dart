import 'package:cloud_firestore/cloud_firestore.dart';

class BarangMasukModel {
  final String? docId;
  final Timestamp tanggal;
  final String idBarang;
  final String namaBarang;
  final int jumlah;
  final String inputOleh;

  BarangMasukModel({
    this.docId,
    required this.tanggal,
    required this.idBarang,
    required this.namaBarang,
    required this.jumlah,
    required this.inputOleh,
  });

  factory BarangMasukModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return BarangMasukModel(
      docId: docId,
      tanggal: map['tanggal'] as Timestamp,
      idBarang: map['id_barang'] as String? ?? '',
      namaBarang: map['nama_barang'] as String? ?? '',
      jumlah: (map['jumlah'] as num).toInt(),
      inputOleh: map['input_oleh'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tanggal': tanggal,
      'id_barang': idBarang,
      'nama_barang': namaBarang,
      'jumlah': jumlah,
      'input_oleh': inputOleh,
    };
  }
}
