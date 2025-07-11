// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:futsal_booking_app/models/user.dart';
import 'package:futsal_booking_app/services/auth_service.dart';
import 'package:futsal_booking_app/utils/constants.dart';

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
      // Logic fallback saldo awal (opsional, tergantung kebutuhan)
      if (_currentUser != null &&
          _currentUser!.role == UserRole.user &&
          _currentUser!.balance < AppConstants.initialBalance / 2 &&
          _currentUser!.id != 'admin_futsal_id') {
        _currentUser!.balance = AppConstants.initialBalance;
        await _authService.updateUser(_currentUser!);
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
        _currentUser = user; // Set current user
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
      final user = await _authService.register(username, email, password);
      if (user != null) {
        // Tidak otomatis login setelah register, biarkan user login secara manual
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
      User updatedUser = User(
        id: _currentUser!.id,
        username: _currentUser!.username,
        email: _currentUser!.email,
        role: _currentUser!.role,
        profileImageUrl: imageUrl,
        balance: _currentUser!.balance,
      );
      await _authService.updateUser(updatedUser);
      _currentUser =
          await _authService.getCurrentUser(); // Muat ulang dari service
      notifyListeners();
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
    _currentUser!.balance -= amount;
    await _authService.updateUser(_currentUser!);
    notifyListeners();
  }

  Future<void> addBalance(double amount) async {
    if (_currentUser == null) {
      throw Exception('Tidak ada pengguna yang sedang login.');
    }
    _currentUser!.balance += amount;
    await _authService.updateUser(_currentUser!);
    notifyListeners();
  }

  double get userBalance => _currentUser?.balance ?? 0.0;
}
