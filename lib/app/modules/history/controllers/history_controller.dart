import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../models/analisis_topsis_model.dart';
import '../../../services/topsis_service.dart';
import '../../topsis/views/topsis_detail_view.dart';

class HistoryController extends GetxController {
  final TopsisService _topsisService = Get.put<TopsisService>(TopsisService());

  final isLoading = false.obs;
  final analysisHistory = <AnalisisTopsisModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnalysisHistory();
  }

  Future<void> fetchAnalysisHistory() async {
    try {
      isLoading.value = true;
      analysisHistory.value = await _topsisService.getAnalysisHistory();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data riwayat: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    try {
      return DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
    } catch (e) {
      return '-';
    }
  }

  void navigateToDetail(AnalisisTopsisModel analysis) {
    Get.to(() => TopsisDetailView(), arguments: analysis);
  }

  Future<void> deleteAnalysis(String? analysisId) async {
    if (analysisId == null) return;

    try {
      Get.dialog(
        AlertDialog(
          title: const Text('Hapus Riwayat'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus riwayat analisis ini?',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                Get.back();
                isLoading.value = true;
                await _topsisService.deleteAnalysis(analysisId);
                await fetchAnalysisHistory();
                Get.snackbar(
                  'Berhasil',
                  'Riwayat analisis berhasil dihapus',
                  backgroundColor: Colors.green.shade100,
                  colorText: Colors.green.shade900,
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus riwayat: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
