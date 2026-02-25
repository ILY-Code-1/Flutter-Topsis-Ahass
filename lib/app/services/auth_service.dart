import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  final GetStorage _storage = GetStorage();

  // Observable untuk status login
  final RxBool isLoggedIn = false.obs;
  final RxString currentUsername = ''.obs;
  final RxString currentRole = ''.obs; // admin atau staff

  // Key untuk local storage
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'username';
  static const String _keyRole = 'role';
  static const String _keyLoginTimestamp = 'login_timestamp';

  // Durasi session: 24 jam dalam milliseconds
  static const int _sessionDuration = 24 * 60 * 60 * 1000; // 24 jam

  @override
  void onInit() {
    super.onInit();
    _loadAuthState();
  }

  // Load auth state dari local storage
  void _loadAuthState() {
    isLoggedIn.value = _storage.read(_keyIsLoggedIn) ?? false;
    currentUsername.value = _storage.read(_keyUsername) ?? '';
    currentRole.value = _storage.read(_keyRole) ?? '';

    // Cek apakah session sudah expired
    if (isLoggedIn.value && _isSessionExpired()) {
      // Jika expired, logout otomatis
      logout();
    }
  }

  // Cek apakah session sudah expired (lebih dari 24 jam)
  bool _isSessionExpired() {
    final loginTimestamp = _storage.read(_keyLoginTimestamp);

    if (loginTimestamp == null) {
      // Jika tidak ada timestamp, anggap expired
      return true;
    }

    final loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
    final currentTime = DateTime.now();
    final difference = currentTime.difference(loginTime).inMilliseconds;

    // Return true jika sudah lebih dari 24 jam
    return difference > _sessionDuration;
  }

  // Login dengan username dan password dari Firebase
  // Login dengan username dan password hardcode
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Simulasi loading
      await Future.delayed(const Duration(milliseconds: 500));

      // Cek username dan password hardcode
      if (username == 'admin' && password == 'admin123') {
        // Login berhasil sebagai admin
        final role = 'admin';

        await _storage.write(_keyIsLoggedIn, true);
        await _storage.write(_keyUsername, username);
        await _storage.write(_keyRole, role);
        await _storage.write(
          _keyLoginTimestamp,
          DateTime.now().millisecondsSinceEpoch,
        );

        isLoggedIn.value = true;
        currentUsername.value = username;
        currentRole.value = role;

        return {
          'success': true,
          'message': 'Login berhasil sebagai Admin',
          'user': {'username': username, 'role': role, 'isActive': true},
        };
      } else if (username == 'user' && password == 'user123') {
        // Login berhasil sebagai user
        final role = 'user';

        await _storage.write(_keyIsLoggedIn, true);
        await _storage.write(_keyUsername, username);
        await _storage.write(_keyRole, role);
        await _storage.write(
          _keyLoginTimestamp,
          DateTime.now().millisecondsSinceEpoch,
        );

        isLoggedIn.value = true;
        currentUsername.value = username;
        currentRole.value = role;

        return {
          'success': true,
          'message': 'Login berhasil sebagai User',
          'user': {'username': username, 'role': role, 'isActive': true},
        };
      } else {
        // Username atau password salah
        return {'success': false, 'message': 'Username atau password salah'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.remove(_keyIsLoggedIn);
    await _storage.remove(_keyUsername);
    await _storage.remove(_keyRole);
    await _storage.remove(_keyLoginTimestamp);

    isLoggedIn.value = false;
    currentUsername.value = '';
    currentRole.value = '';
  }

  // Cek apakah user sudah login dan session masih valid
  bool get isAuthenticated {
    if (!isLoggedIn.value) {
      return false;
    }

    // Cek apakah session expired
    if (_isSessionExpired()) {
      // Auto logout jika expired
      logout();
      return false;
    }

    return true;
  }

  // Get username yang sedang login
  String get username => currentUsername.value;

  // Get role user yang sedang login
  String get role => currentRole.value;

  // Cek apakah user adalah admin
  bool get isAdmin => currentRole.value == 'admin';

  // Cek apakah user adalah staff
  bool get isStaff =>
      currentRole.value == 'staff' || currentRole.value == 'user';
}
