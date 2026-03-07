import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../themes/themes.dart';
import '../widgets/add_user_dialog.dart';
import '../widgets/edit_user_dialog.dart';

class UserManagementController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  final isLoading = false.obs;
  final users = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      users.value = await _userService.getUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data user: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showAddUserDialog() {
    Get.dialog(
      AddUserDialog(onSubmit: _addUser),
      barrierDismissible: false,
    );
  }

  Future<void> _addUser(
    String username,
    String password,
    String role,
  ) async {
    try {
      isLoading.value = true;

      final user = UserModel(
        id: '',
        username: username,
        password: password,
        role: role,
        isActive: true,
      );

      await _userService.addUser(user);

      Get.snackbar(
        'Berhasil',
        'User "$username" berhasil ditambahkan',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.TOP,
      );

      await fetchUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan user: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void showEditUserDialog(UserModel user) {
    Get.dialog(
      EditUserDialog(
        user: user,
        onSubmit: (username, password, role) =>
            _updateUser(user.id, username, password, role),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _updateUser(
    String userId,
    String username,
    String password,
    String role,
  ) async {
    try {
      isLoading.value = true;
      final updated = UserModel(
        id: userId,
        username: username,
        password: password,
        role: role,
        isActive: users.firstWhere((u) => u.id == userId).isActive,
      );
      await _userService.updateUser(updated);
      Get.snackbar(
        'Berhasil',
        'Perubahan user berhasil disimpan',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.TOP,
      );
      await fetchUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah user: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleStatus(String userId, bool currentStatus) {
    final newStatusLabel = currentStatus ? 'nonaktifkan' : 'aktifkan';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              currentStatus ? Icons.toggle_off_rounded : Icons.toggle_on_rounded,
              color: currentStatus ? AppColors.error : AppColors.success,
            ),
            const SizedBox(width: 12),
            Text('Konfirmasi ${currentStatus ? 'Nonaktifkan' : 'Aktifkan'}'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin $newStatusLabel user ini?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _toggleStatusConfirmed(userId, currentStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  currentStatus ? AppColors.error : AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              currentStatus ? 'Nonaktifkan' : 'Aktifkan',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleStatusConfirmed(
    String userId,
    bool currentStatus,
  ) async {
    try {
      isLoading.value = true;
      await _userService.toggleStatus(userId, currentStatus);

      Get.snackbar(
        'Berhasil',
        'Status user berhasil ${currentStatus ? 'dinonaktifkan' : 'diaktifkan'}',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.TOP,
      );

      await fetchUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah status user: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void deleteUser(String userId, String username) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus user "$username"?\nTindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _deleteUserConfirmed(userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUserConfirmed(String userId) async {
    try {
      isLoading.value = true;
      await _userService.deleteUser(userId);

      Get.snackbar(
        'Berhasil',
        'User berhasil dihapus',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.TOP,
      );

      await fetchUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus user: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
