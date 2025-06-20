// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:futsal_booking_app/models/user.dart';
import 'package:futsal_booking_app/services/auth_service.dart';
import 'package:futsal_booking_app/utils/constants.dart'; // Untuk AppConstants.initialBalance

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final AuthService _authService = AuthService();

  // Constructor untuk memuat user saat app dimulai
  AuthProvider() {
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser != null &&
          _currentUser!.role == UserRole.user &&
          _currentUser!.balance == 0.0) {
        // Ini adalah fallback jika user lama terdaftar tanpa saldo, berikan saldo awal
        // HANYA jika saldonya 0.0. Hati-hati dengan ini di produksi.
        // Untuk demo, kita bisa paksakan saldo awal jika 0.
        // Dalam produksi, ini lebih baik diatur saat register
        // atau migrasi data.
        if (_currentUser!.balance < AppConstants.initialBalance / 2 &&
            _currentUser!.id != 'admin_futsal_id') {
          // Contoh kondisi
          _currentUser!.balance = AppConstants.initialBalance;
          await _authService.updateUser(_currentUser!);
        }
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data pengguna: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(username, password);
      if (user != null) {
        _currentUser = user;
        // setCurrentUser sudah dipanggil di AuthService.login
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Username atau password salah.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // AuthService.register sekarang otomatis memberikan saldo awal
      final user = await _authService.register(username, email, password);
      if (user != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.logout();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfileImage(String imageUrl) async {
    if (_currentUser != null) {
      _currentUser = User(
        // Buat objek User baru dengan URL gambar baru
        id: _currentUser!.id,
        username: _currentUser!.username,
        email: _currentUser!.email,
        role: _currentUser!.role,
        profileImageUrl: imageUrl,
        balance: _currentUser!.balance, // Penting: Pertahankan saldo lama
      );
      await _authService.updateUser(_currentUser!); // Simpan ke service
      // loadCurrentUser() akan otomatis memperbarui _currentUser
      notifyListeners(); // Trigger rebuild
    }
  }

  // --- Metode untuk mengelola saldo pengguna ---
  Future<void> debitBalance(double amount) async {
    if (_currentUser == null || _currentUser!.role != UserRole.user) {
      throw Exception('Hanya pengguna yang dapat melakukan transaksi.');
    }
    if (_currentUser!.balance < amount) {
      throw Exception('Saldo tidak cukup untuk transaksi ini.');
    }
    _currentUser!.balance -= amount; // Kurangi saldo
    await _authService.updateUser(_currentUser!); // Simpan perubahan saldo
    notifyListeners(); // Beritahu listener bahwa saldo berubah
  }

  Future<void> addBalance(double amount) async {
    if (_currentUser == null || _currentUser!.role != UserRole.user) {
      throw Exception('Hanya pengguna yang dapat melakukan transaksi.');
    }
    _currentUser!.balance += amount; // Tambah saldo
    await _authService.updateUser(_currentUser!); // Simpan perubahan saldo
    notifyListeners(); // Beritahu listener bahwa saldo berubah
  }

  // Metode untuk menampilkan saldo saat ini dari user yang sedang login
  double get userBalance => _currentUser?.balance ?? 0.0;
}
